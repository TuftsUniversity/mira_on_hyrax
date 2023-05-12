# XML Batching Loading in MIRA

## Problem we're trying to solve

When an object with an embargo is created by XML ingest, the associated file is tagged with a Visibility of Private, regardless of the Visibility of the metadata.  Sometime after the embargo expires, the embargo is removed, but the Private setting on the file is not changed.  So the object is not visible in the TDL unless the Visibility of the file is changed manually

## Views
`app/views/hyrax/xml_imports/*.html.erb`

* probably not much to change here, but thats where they are.

## Controllers
`app/controllers/hyrax/xml_imports_controller.rb`

* probably not much to change here, it is basically pushing work down and delegating into other classes, useful for seeing the actions though.

## Routes

* You can list routes to see what the application is publishing for actions around batch import too:

```
                      xml_imports POST     /xml_imports(.:format)                                                                   hyrax/xml_imports#create
                   new_xml_import GET      /xml_imports/new(.:format)                                                               hyrax/xml_imports#new
                  edit_xml_import GET      /xml_imports/:id/edit(.:format)                                                          hyrax/xml_imports#edit
                       xml_import GET      /xml_imports/:id(.:format)                                                               hyrax/xml_imports#show
                                  PATCH    /xml_imports/:id(.:format)                                                               hyrax/xml_imports#update
                                  PUT      /xml_imports/:id(.:format)                                                               hyrax/xml_imports#update
```

To give you some clues where to look in the code.

## Models
`app/models/xml_import.rb`

* The model here binds the uploaded XML to a class.
* It has access to the parser `MiraXmlImporter`
* Has access to the minter, that generats IDs for items in Fedora
* Access to the batch it belongs to
* The original XML file.
* Kicks off asynchronous jobs that do the actual import
* Facilitates a lot of the mechanics of import but doesn't really manipulate the data.

## Libs

Lot going on here, has some possibility to be relevant to this issue:

There's a generic importer at:

`app/lib/tufts/importer.rb` 

This is sort of a abstract class, but it does contain common implementation stuff that gets used in the mira xml importer.  

This is the more specific implemenation:

`app/lib/tufts/mira_xml_importer.rb`

Again though its not really manipulating data at the field level though, and thats the bug we're looking for here.

## Jobs

`app/lib/import_job.rb`

* Does one thing runs a import service to import an object.  But good to keep in mind now that whatever is happening is probably happening asynchronously.

## Services

`app/serverices/tufts/import_service.rb`

* Here we get to where the records get built, and that points to `Tufts::ImportRecord`

## Tufts::ImportRecord (back to libs)


* Here you can see the `visibility` being applied to the metadata record, but not the fileset, and that sort of specifically is the issue we're looking for so thats a good place to look.
* Looking through here you can get an idea of the object is set up and structured but there's really not a lot of good information on how that gets conveyed up to the FileSet(s).

## Where do you go from here?

* So now you can sort of see, where the visibility flags are getting applied, and you should be thinking, well where is the FileSet itself getting built because thats where its not being applied.
* You're also looking at Tufts::ImportRecord and seeing some stuff for file_types and that's probably used in the FileSet code, so you could look to see where that's being used.

## Actor Stack
* So if you look where that is being used you get to:
* `app/actors/hyrax/create_with_files_and_pass_types.rb`
* And you start looking through here and see a new job `AttachTypedFilesToWork`

## AttachTypedFilesToWorkJob
* `app/jobs/attach_typed_files_to_work_job.rb`
* So you get here, and you see the FileSet being created, and this starts to look like where the problem is happening most likely, if you look deeper past here, you'll be in Core Hyrax Code in the hyrax gem.


## And so whats the fix?

* There's really 2-ish paths to take here I think at first glance, the 1st would be to look at how the file_types are getting pushed around to this code, and do something similar with the embargo fields.

* The 2nd is to debug this into the hyrax gem and see what its doing with the visibility fields, and why and try to conform with what it expects.

* The 3rd, I would delve into the parent class `AttachFilesToWorkJob` I think this is the right path.  `AttachTypedFilesToWorkJob` messes with visibility on line 10. and that method is in the parent class:
```

    # The attributes used for visibility - sent as initial params to created FileSets.
    def visibility_attributes(attributes)
      attributes.slice(:visibility, :visibility_during_lease,
                       :visibility_after_lease, :lease_expiration_date,
                       :embargo_release_date, :visibility_during_embargo,
                       :visibility_after_embargo)
    end
```

And so I look at that And I think I need to get that populated so that the parent here can properly set the embargo, so I would start with that goal and work backwards from there.

