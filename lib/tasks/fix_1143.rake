# frozen_string_literal: true
# rubcop:disable Layout/LineLength
require 'active_fedora'

namespace :tufts do
  desc 'TDLR-1143 - Move Corporate Name into Creator Department'

  task fix_1143: :environment do
    if ARGV.size != 2
      puts('example usage: rake tufts:fix_1143 1143_pids.txt')
    else

      # Sources for Creator Department vs Corporate Name:
      # All creator depts associated with UA005 numbers (ie, Senior Honors Theses) came from Adrienne Pruitt in two emailed lists.
      # Senior Honors Theses are also documented here: https://archives.tufts.edu/repositories/2/resources/123
      # Tisch shared a wiki page: https://wikis.uit.tufts.edu/confluence/pages/viewpage.action?spaceKey=TischTech&title=ETDs+--+Tufts+Departments+and+Programs
      # Tisch created a spreadsheet: https://tufts.app.box.com/s/ao238j70hurr2sfdl3kyc7v593yq4627
      # Many of the creator depts are duplicated below but known_creator_depts is a ruby Set, so it will have only one instance.

      # These names should be fixed in Creator Department and/or Corporate Name.
      names_to_fix = {
        # Change "Department of" to "Graduate Program in".
        "Tufts Graduate School of Biomedical Sciences. Department of Cell, Molecular and Developmental Biology." => "Tufts Graduate School of Biomedical Sciences. Graduate Program in Cell, Molecular and Developmental Biology.",
        "Tufts Graduate School of Biomedical Sciences. Department of Clinical and Translational Science." => "Tufts Graduate School of Biomedical Sciences. Graduate Program in Clinical and Translational Science.",
        "Tufts Graduate School of Biomedical Sciences. Department of Genetics." => "Tufts Graduate School of Biomedical Sciences. Graduate Program in Genetics.",
        "Tufts Graduate School of Biomedical Sciences. Department of Immunology." => "Tufts Graduate School of Biomedical Sciences. Graduate Program in Immunology.",
        "Tufts Graduate School of Biomedical Sciences. Department of Molecular Microbiology." => "Tufts Graduate School of Biomedical Sciences. Graduate Program in Molecular Microbiology.",
        "Tufts Graduate School of Biomedical Sciences. Department of Pharmacology and Experimental Therapeutics." => "Tufts Graduate School of Biomedical Sciences. Graduate Program in Pharmacology and Drug Development.",
        "Tufts University. Department of Pharmacology and Drug Development." => "Tufts Graduate School of Biomedical Sciences. Graduate Program in Pharmacology and Drug Development.",
        "Tufts University. Deptartment of Pharmacology and Drug Development." => "Tufts Graduate School of Biomedical Sciences. Graduate Program in Pharmacology and Drug Development.",
        # Add trailing period.
        "Tufts Graduate School of Biomedical Sciences. Graduate Program in Cell, Molecular and Developmental Biology" => "Tufts Graduate School of Biomedical Sciences. Graduate Program in Cell, Molecular and Developmental Biology.",
        "Tufts Graduate School of Biomedical Sciences. Graduate Program in Clinical and Translational Science" => "Tufts Graduate School of Biomedical Sciences. Graduate Program in Clinical and Translational Science.",
        "Tufts Graduate School of Biomedical Sciences. Graduate Program in Immunology" => "Tufts Graduate School of Biomedical Sciences. Graduate Program in Immunology.",
        "Tufts Graduate School of Biomedical Sciences. Neuroscience Program" => "Tufts Graduate School of Biomedical Sciences. Neuroscience Program.",
        # Change "&amp;" to "&".
        "Gerald J. &amp; Dorothy R. Friedman School of Nutrition Science and Policy." => "Gerald J. & Dorothy R. Friedman School of Nutrition Science and Policy.",
        "Gerald J. &amp; Dorothy R. Friedman School of Nutrition Science and Policy. Nutrition Innovation Lab." => "Gerald J. & Dorothy R. Friedman School of Nutrition Science and Policy. Nutrition Innovation Lab.",
        # Add comma before "and".
        "Tufts University. Department of Theatre, Dance and Performance Studies." => "Tufts University. Department of Theatre, Dance, and Performance Studies.",
        # Add "Department of".
        "Tufts University. International Literary and Cultural Studies." => "Tufts University. Department of International Literary and Cultural Studies."
      }

      # These names should be left in whichever of Creator Department and/or Corporate Name they currently appear.
      names_to_leave = Set[
        "Tufts University. School of Dental Medicine.", # Dental School can legitimately be either creator dept or corp name.  Steve says that the 12 works that are in creator dept should stay there.
      ]

      # If these creator depts are encountered in Corporate Name they should be moved to Creator Department.
      # Any creator dept not in this set should be flagged as unknown.
      known_creator_depts = Set[
        "Tufts University. Department of History.",                                             # UA005.001
        "Tufts University. Department of Philosophy.",                                          # UA005.002
        "Tufts University. Department of Economics.",                                           # UA005.003
        "Tufts University. International Relations Program.",                                   # UA005.004  new UA005 List says "Program in International Relations"
        "Tufts University. Department of English.",                                             # UA005.005
        "Tufts University. Department of Psychology.",                                          # UA005.006
        "Tufts University. Department of Political Science.",                                   # UA005.007
        "Tufts University. American Studies Program.",                                          # UA005.008  new UA005 list says "Program in American Studies"
        "Tufts University. Eliot-Pearson Department of Child Development.",                     # UA005.009  fixed by Brian (added period) - new UA005 list says "Department of Child Development"
        "Tufts University. Department of Biology.",                                             # UA005.010
        "Tufts University. Department of Anthropology.",                                        # UA005.011  new UA005 list says "Department of Sociology/Anthropology"
        "Tufts University. Department of Chemical and Biological Engineering.",                 # UA005.012
        "Tufts University. Department of Art and Art History.",                                 # UA005.013
        "Tufts University. Department of German, Russian and Asian Languages and Literatures.", # UA005.014  new UA005 list says "Department of German, Russian, and Asian Languages and Literatures" (comma before "and", but this is incorrect)
        "Tufts University. Department of Chemistry.",                                           # UA005.015
        "Tufts University. Department of Biomedical Engineering.",                              # UA005.019
        "Tufts University. Department of Romance Languages.",                                   # UA005.020
        "Tufts University. Department of Physics and Astronomy.",                               # UA005.022
        "Tufts University. Department of Religion.",                                            # UA005.024
        "Tufts University. Department of Classics.",                                            # UA005.025
        "Tufts University. Department of Drama and Dance.",                                     # UA005.026
        "Tufts University. Women's Studies Program.",                                           # UA005.027
        "Tufts University. Department of Mechanical Engineering.",                              # UA005.028  added by Brian
        "Tufts University. Program in Engineering Psychology.",                                 # UA005.029  fixed by Brian (was Department of Mechanical Engineering) - not on the Tisch wiki page
        "Tufts University. Program in Archeology.",                                             # UA005.030  added by Brian - not on the Tisch wiki page - new UA005 list says "Program in Archaeology"
        "Tufts University. Community Health Program.",                                          # UA005.031  new UA005 list says "Program in Community Health"
        "Tufts University. Department of Mathematics.",                                         # UA005.032
        "Tufts University. International Literary and Visual Studies.",                         # UA005.033  not on the Tisch wiki page - new UA005 list says "Department of International Letters and Visual Studies"
        "Tufts University. Department of Music.",                                               # UA005.034
        "Tufts University. Department of Electrical and Computer Engineering.",                 # UA005.035
        "Tufts University. Department of Computer Science.",                                    # UA005.036
        "Tufts University. Department of Earth and Ocean Sciences.",                            # UA005.038  not on the Tisch wiki page - new UA005 list says "Department of Geology"
        "Tufts University. Peace and Justice Studies Program.",                                 # UA005.039  added by Brian - new UA005 list says "Program in Peace and Justice Studies"
        "Tufts University. Department of Civil and Environmental Engineering.",                 # UA005.040
        "Tufts University. Center for Interdisciplinary Studies.",                              # UA005.043
        "Cummings School of Veterinary Medicine.",                                              # Adrienne says this is a department
        # "Tufts University. Fares Center for Eastern Mediterranean Studies.",                  # Previously on the Tisch wiki page, but currently not on the Tisch wiki page - there are no matches in our metadata
        # "Tufts University. Graduate School of Arts and Sciences.",                            # Previously on the Tisch wiki page, but currently not on the Tisch wiki page - Tisch spreadsheet says change to "Tufts University. Center for Interdisciplinary Studies."  Only one match, fixed manually: js956v637
        "Fletcher School of Law and Diplomacy.",
        "Gerald J. & Dorothy R. Friedman School of Nutrition Science and Policy.",
        "Museum of Fine Arts, Boston. School.",                                                 # former (until July, 2016; changed to Tufts University. School of the Museum of Fine Arts.)
        "Sackler School of Graduate Biomedical Sciences.",                                      # former (until 2019; changed to Tufts Graduate School of Biomedical Sciences.)
        "Tufts Graduate School of Biomedical Sciences.",
        "Tufts Graduate School of Biomedical Sciences. Graduate Program in Cell, Molecular and Developmental Biology.",
        "Tufts Graduate School of Biomedical Sciences. Graduate Program in Clinical and Translational Science.",
        "Tufts Graduate School of Biomedical Sciences. Graduate Program in Genetics.",
        "Tufts Graduate School of Biomedical Sciences. Graduate Program in Immunology.",
        "Tufts Graduate School of Biomedical Sciences. Graduate Program in Molecular Microbiology.",
        "Tufts Graduate School of Biomedical Sciences. Graduate Program in Pharmacology and Drug Development.",
        "Tufts Graduate School of Biomedical Sciences. Neuroscience Program.",
        "Tufts Graduate School of Biomedical Sciences. Department of Biochemistry.",            # Adrienne says this was a department until 2020.
        "Tufts University. Africana Studies.",                                                  # new UA005 list says "Department of Africana Studies"
        "Tufts University. American Studies Program.",
        "Tufts University. Asian American Studies.",                                            # new UA005 list says "Program in Asian Studies, 1999 -- 2013  UA005.017"
        "Tufts University. Center for Interdisciplinary Studies.",
        "Tufts University. Colonialism Studies.",
        "Tufts University. Communications and Media Studies.",                                  # former (until fall 2015; changed to Tufts University. Film and Media Studies.)
        "Tufts University. Community Health Program.",
        "Tufts University. Department of Anthropology.",
        "Tufts University. Department of Art and Art History.",                                 # former (until 2020; changed to Tufts University. Department of the History of Art and Architecture.)
        "Tufts University. Department of Biology.",
        "Tufts University. Department of Biomedical Engineering.",
        "Tufts University. Department of Chemical and Biological Engineering.",
        "Tufts University. Department of Chemistry.",
        "Tufts University. Department of Civil and Environmental Engineering.",
        "Tufts University. Department of Classical Studies.",                                   # current (since 2020; changed from Tufts University. Department of Classics.)
        "Tufts University. Department of Classics.",                                            # former (until 2020; changed to Tufts University. Department of Classical Studies.)
        "Tufts University. Department of Computer Science.",
        "Tufts University. Department of Drama and Dance.",                                     # former (until 2019; changed to Tufts University. Department of Theatre, Dance, and Performance Studies.)
        "Tufts University. Department of Economics.",
        "Tufts University. Department of Education.",
        "Tufts University. Department of Electrical and Computer Engineering.",
        "Tufts University. Department of English.",
        "Tufts University. Department of German, Russian and Asian Languages and Literatures.", # former (until 2016; changed to Tufts University. Department of International Literary and Cultural Studies.)
        "Tufts University. Department of History.",
        "Tufts University. Department of International Literary and Cultural Studies.",         # current (since 2016; changed from Tufts University. Department of German, Russian and Asian Languages and Literatures.)  Alicia says: "Tufts University. International Literary and Cultural Studies." is a variant.  See https://ase.tufts.edu/ilcs/.
        "Tufts University. Department of Mathematics.",
        "Tufts University. Department of Mechanical Engineering.",
        "Tufts University. Department of Music.",
        "Tufts University. Department of Philosophy.",
        "Tufts University. Department of Physics and Astronomy.",
        "Tufts University. Department of Political Science.",
        "Tufts University. Department of Psychology.",
        "Tufts University. Department of Religion.",
        "Tufts University. Department of Romance Languages.",                                   # current (since 2018; changed from Tufts University. Department of Romance Studies.)
        "Tufts University. Department of Romance Studies.",                                     # former (until 2018; changed to Tufts University. Department of Romance Languages.)
        "Tufts University. Department of Sociology.",
        "Tufts University. Department of Studies in Race, Colonialism, and Diaspora.",
        "Tufts University. Department of the History of Art and Architecture.",                 # current (since 2020, changed from Tufts University. Department of Art and Art History.)
        "Tufts University. Department of Theatre, Dance, and Performance Studies.",             # current (since 2019; changed from Tufts University. Department of Drama and Dance.)
        "Tufts University. Department of Urban and Environmental Policy and Planning.",         # Alicia says this is is in the Graduate School of Arts and Sciences (different entity from "Tufts University. Environmental Studies Program.")
        "Tufts University. Eliot-Pearson Department of Child Development.",                     # former (until May, 2014; changed to Tufts University. Eliot-Pearson Department of Child Study and Human Development.)
        "Tufts University. Eliot-Pearson Department of Child Study and Human Development.",     # current (since May, 2014, changed from Tufts University. Eliot-Pearson Department of Child Development.)
        "Tufts University. Environmental Studies Program.",                                     # Alicia says this is a multidisciplinary undergraduate program in the School of Arts and Sciences and School of Engineering (different entity from "Tufts University. Department of Urban and Environmental Policy and Planning.")
        "Tufts University. Film and Media Studies.",                                            # current (since fall 2015; changed from Tufts University. Communications and Media Studies.)
        "Tufts University. International Relations Program.",
        "Tufts University. Latin American Studies.",                                            # new UA005 list says "Department of Latin American Studies".  Alicia says is its own department (distinct from "Tufts University. Latino Studies.").
        "Tufts University. Latino Studies.",                                                    # Alicia says: Latino (or Latinx) Studies is a part of "Tufts University. Department of Studies in Race, Colonialism, and Diaspora.".
        "Tufts University. Middle Eastern Studies.",                                            # new UA005 list says "Program in Middle Eastern Studies"
        "Tufts University. Native American and Indigenous Studies.",
        "Tufts University. Occupational Therapy Department.",
        "Tufts University. Peace and Justice Studies Program.",
        "Tufts University. School of the Museum of Fine Arts.",                                 # current (since July, 2016; changed from Museum of Fine Arts, Boston. School.)
        "Tufts University. Women's Studies Program.",                                           # former (until July 2013; changed to Tufts University. Women's, Gender, and Sexuality Studies Program.) - new UA005 list says "Program in Women's Studies"
        "Tufts University. Women's, Gender, and Sexuality Studies Program.",                    # current (since July 2013; changed from Tufts University. Women's Studies Program.)
        "Tufts University. Science, Technology, and Society.",                                  # https://as.tufts.edu/sts/majorminor says the Science, Technology, and Society program offers a 10-course co-major and a 6-course minor.  Steve says this is a creator dept.
        "Tufts University. Asian Studies.",
        "Tufts University. Department of Earth and Ocean Sciences.",                            # current name of Tufts University. Department of Geology.
        "Tufts University. Department of Geology.",                                             # former name of Tufts University. Department of Earth and Ocean Sciences.
        "Tufts University. Department of Urban and Environmental Policy.",                      # former name of Tufts University. Department of Urban and Environmental Policy and Planning.
        "Tufts University. Institute for Global Leadership.",
        "Tufts University. International Literary and Visual Studies.",                         # https://ase.tufts.edu/ilvs
        "Tufts University. Public Health and Professional Degree Programs.",
      ]

      # These corporate names should be left in Corporate Name.
      # Any corporate name not in this set should be flagged as unknown.
      known_corp_names = Set[
        "Abu Ghraib Prison.",
        "Alibaba (Firm)",
        "Amazon.com (Firm)",
        "Ambassador's Fund for Cultural Preservation (U.S.)",
        "Arnold Arboretum--Environmental aspects.",                                       # subject???
        "Bank al-Markazī al-Urdunī.",
        "Barnard College.",
        "Biscayne National Park (Agency : U.S.)",
        "BRAC (Organization)",
        "Charlestown High School (Boston, Mass.)",
        "Chile. Comisión Nacional de Verdad y Reconciliación",
        "Coca-Cola Company.",
        "Dudley Street Neighborhood Initiative.",
        "European Union",
        "Federal Theatre Project (U.S.)",
        "Federal Theatre Project.",
        "Feed the Future Innovation Lab for Nutrition.",
        "Fermi National Accelerator Laboratory",
        "Group of Twenty",
        "Gulf Cooperation Council.",
        "Healthy Families America (Program)",
        "Heifer International.",
        "Himalayan College of Agricultural Sciences & Technology (Kathmandu, Nepal)",
        "Hizballah (Lebanon)",
        "International Court of Justice",
        "International Labour Organization. Better Factories Cambodia",
        "Johns Hopkins Bloomberg School of Public Health.",
        "Kommunisticheskai͡a partii͡a Sovetskogo Soi͡uza--Purges.",                       # subject???
        "LabNet (Project)",
        "LEGO Systems, Inc.",
        "Major League Baseball (Organization)",
        "Massachusetts Bay Transportation Authority",
        "Massachusetts Butterfly Club",
        "Massachusetts. Department of Public Utilities",
        "Musée du Louvre.",
        "National Republican Party (U.S.)",
        "Nepal Agricultural Research Council.",
        "New York (State). Metropolitan Transportation Authority.",
        "Nuclear Suppliers Group.",
        "Nutrition Collaborative Research Support Program.",
        "Olympic Games (28th : 2004 : Athens, Greece)",
        "Palm Computing (Firm)",
        "Partners in Flight.",
        "Pūrvāñcala Viśvavidyālaya.",
        "Radcliffe College.",
        "Renaissance Middle School (Montclair, N.J.)",
        "Republican Party (U.S. : 1854- )",
        "Rossiĭskai︠a︡ sot︠s︡ial-demokraticheskai︠a︡ rabochai︠a︡ partii︠a︡ (bolʹshevikov)",
        "Scotland. Sovereign (1567-1625 : James VI)",
        "Shanghai World Expo (2010 : China)",
        "St. Giles' Cathedral (Edinburgh, Scotland)",
        "St. Patrick's Cathedral (Dublin, Ireland)",
        "Tribhuvana Viśvavidyālaya. Institute of Agriculture and Animal Sciences.",
        "U.S. Fish and Wildlife Service.",
        "United States Military Academy",
        "United States--Armed forces.",                                                   # subject???
        "United States. Agency for International Development.",
        "United States. Animal Welfare Act of 1970.",
        "United States. Congress.",
        "United States. Endangered Species Act of 1973",
        "United States. Marine Corps--Afghanistan.",                                      # subject???
        "United States. National Aeronautics and Space Administration.",
        "United States. Patient Protection and Affordable Care Act.",
        "United States. President (2017- : Trump)",                                       # subject???
        "United States. President's Emergency Plan for AIDS Relief",
        "United States. Supreme Court.",
        "Universidad Veracruzana.",
        "University of Ghana.",
        "University of Massachusetts at Boston",
        "Wellesley College",
        "World Bank",
        "World Bank.",
        "Jackson College for Women (Tufts University)",                                   # spreadsheet says [this is a subject, keep in Corporate] - Adrienne agrees
        "Kritzer Laboratory (Tufts University)",                                          # spreadsheet says [no authority, not a department; keep in Corporate? delete?] - Adrienne agrees it's a corp name
        "Tufts University.",                                                              # spreadsheet says Tufts University.  [check item-may be general student or faculty  scholarship]
        "Tufts University",                                                               # spreadsheet says Tufts University.  [check item-may be general student or faculty  scholarship]
        "Tufts University. Office of Sustainability.",                                    # spreadsheet says [student scholarship, not a degree-granting department; keep in Corporate]
        "Tufts University. Center for Animals and Public Policy.",                        # Steve says not a degree-granting program, should stay in corporate name
        "Tufts Institute of the Environment.",                                            # https://swm.tufts.edu/about says TIE is part of Friedman School of Nutrition and grants the MSSWM degree.  Steve says this should be a corp name.
        "Feinstein International Center.",                                                # fic.tufts.edu says: "The Feinstein International Center is a research and teaching center based at the Friedman School of Nutrition Science and Policy at Tufts University."  Steve says this should be a corp name.  Fix fq978670 manually.
        "Gerald J. & Dorothy R. Friedman School of Nutrition Science and Policy. Nutrition Innovation Lab.", # Steve says this is a corp name
        "Tufts University. School of Engineering.",                                       # Steve says this is a corp name
        "Tufts University. School of Medicine.",                                          # Steve says this is a corp name
        "North Atlantic Treaty Organization",                                             # discovered in the new works added since Part 2 began
      ]

      # Sanity check: known_creator_depts and known_corp_names should not both contain the same member.
      mistakes = known_creator_depts & known_corp_names

      mistakes.each do |mistake|
        puts("WARNING: #{mistake} IS A MEMBER OF BOTH known_creator_depts AND known_corp_names!")
      end

      # Sanity check: no key from names_to_fix should be a member of known_creator_depts.
      names_to_fix_keys = names_to_fix.keys.to_set
      mistakes = names_to_fix_keys & known_creator_depts

      mistakes.each do |mistake|
        puts("WARNING: #{mistake} IS BOTH A KEY IN names_to_fix AND A MEMBER OF known_creator_depts!")
      end

      # Sanity check: no key from names_to_fix should be a member of known_corp_names.
      mistakes = names_to_fix_keys & known_corp_names

      mistakes.each do |mistake|
        puts("WARNING: #{mistake} IS BOTH A KEY IN names_to_fix AND A MEMBER OF known_corp_names!")
      end

      # Sanity check: every value from names_to_fix should be in known_creator_depts or known_corp_names.
      mistakes = names_to_fix.values.to_set - (known_creator_depts | known_corp_names)

      mistakes.each do |mistake|
        puts("WARNING: #{mistake} IS A VALUE IN names_to_fix BUT IS NOT A MEMBER OF EITHER known_creator_depts OR known_corp_names!")
      end

      # Sanity check: no value from names_to_leave should be in known_creator_depts.
      mistakes = names_to_leave & known_creator_depts

      mistakes.each do |mistake|
        puts("WARNING: #{mistake} IS A MEMBER OF BOTH names_to_leave AND known_creator_depts!")
      end

      # Sanity check: no value from names_to_leave should be in known_corp_names.
      mistakes = names_to_leave & known_corp_names

      mistakes.each do |mistake|
        puts("WARNING: #{mistake} IS A MEMBER OF BOTH names_to_leave AND known_corp_names!")
      end

      collections_of_interest = ["Electronic Theses and Dissertations", "Faculty Scholarship", "Senior honors theses", "Student Scholarship"]

      fixed_creator_depts = Set[]
      fixed_corp_names = Set[]
      misfiled_creator_depts = Set[]
      misfiled_corp_names = Set[]
      unknown_creator_depts = Set[]
      unknown_corp_names = Set[]
      caused_exceptions = Set[]

      filename = ARGV[1]

      puts("id|creator department before|corporate name before|actions|creator department after|corporate name after|member of collection")

      File.readlines(filename).each do |line|
        id = line.strip
        msg = ""

        begin
          next if id.blank?

          work = ActiveFedora::Base.find(id)

          creator_depts = work[:creator_department].to_a
          corp_names = work[:corporate_name].to_a
          member_ofs = work[:member_of_collections]

          work_is_modified = false
          corp_names_to_remove = []
          actions_msg = ""
          msg = ""

          # ---------- Output creator departments and corporate names before changes. ----------

          msg += "|#{creator_depts.join(', ')}|#{corp_names.join(', ')}"

          # ---------- Make any changes to creator departments and corporate names. ----------

          creator_depts.each_with_index do |creator_dept, index|
            fixed_creator_dept = names_to_fix[creator_dept]

            unless fixed_creator_dept.nil?
              # Fix creator_dept unless doing so would create a duplicate.
              is_duplicate = creator_depts.include?(fixed_creator_dept)
              fixed_creator_depts.add("#{creator_dept} => #{fixed_creator_dept}#{is_duplicate ? ' (WARNING! DUPLICATE!)' : ''}")
              actions_msg += "#{actions_msg == '' ? '' : ', '}#{is_duplicate ? 'FIX CREATOR DEPT MANUALLY' : 'fixed creator dept'}"

              unless is_duplicate
                creator_depts[index] = fixed_creator_dept
                creator_dept = fixed_creator_dept
                work_is_modified = true
              end
            end

            # Some names are to be left as they are.
            next if names_to_leave.include?(creator_dept)

            # If creator_dept belongs in corp_names, add a note to actions_msg.
            # This is a rare situation and should be fixed manually.
            if known_corp_names.include?(creator_dept)
              misfiled_corp_names.add(creator_dept)
              actions_msg += "#{actions_msg == '' ? '' : ', '}MOVE CORP NAME FROM CREATOR DEPT MANUALLY"
            else
              # If creator_dept is unknown, add it to unknown_creator_depts.
              unknown_creator_depts.add(creator_dept) unless known_creator_depts.include?(creator_dept)
            end
          end

          corp_names.each_with_index do |corp_name, index|
            fixed_corp_name = names_to_fix[corp_name]

            unless fixed_corp_name.nil?
              # Fix corp_name unless doing so would create a duplicate.
              is_duplicate = corp_names.include?(fixed_corp_name)
              fixed_corp_names.add("#{corp_name} => #{fixed_corp_name}#{is_duplicate ? ' (WARNING! DUPLICATE!)' : ''}")
              actions_msg += "#{actions_msg == '' ? '' : ', '}#{is_duplicate ? 'FIX CORP NAME MANUALLY' : 'fixed corp name'}"

              unless is_duplicate
                corp_names[index] = fixed_corp_name
                corp_name = fixed_corp_name
                work_is_modified = true
              end
            end

            # Some names are to be left as they are.
            next if names_to_leave.include?(corp_name)

            if known_creator_depts.include?(corp_name)
              # Add corp_name to creator_depts unless doing so would create a duplicate.
              # Remove corp_name from corp_names.
              is_duplicate = creator_depts.include?(corp_name)
              misfiled_creator_depts.add(corp_name)
              actions_msg += "#{actions_msg == '' ? '' : ', '}#{is_duplicate ? 'removed creator dept from corp name' : 'moved creator dept from corp name'}"
              creator_depts << corp_name unless is_duplicate
              corp_names_to_remove << corp_name # Remember corp_name to be removed from corp_names later, outside of this .each block.
              work_is_modified = true
            else
              # If corp_name is unknown, add it to unknown_corp_names.
              unknown_corp_names.add(corp_name) unless known_corp_names.include?(corp_name)
            end
          end

          # Remove from corp_names each corp_name that was moved to creator_depts.
          corp_names_to_remove.each do |corp_name|
            corp_names.delete(corp_name)
          end

          msg += "|#{actions_msg}"

          if work_is_modified
            should_actually_save = true

            if should_actually_save
              # ActiveTriples::Relation will not save the work without these two assignments!
              work[:creator_department] = creator_depts
              work[:corporate_name] = corp_names
              work.save!

              # Fetch the work again to verify that it has been changed.
              work = ActiveFedora::Base.find(id)
              creator_depts = work[:creator_department].to_a
              corp_names = work[:corporate_name].to_a
            end
          end

          # ---------- Output creator departments and corporate names after changes. ----------

          msg += "|#{creator_depts.join(', ')}|#{corp_names.join(', ')}"

          #  ---------- Output member_of_collections. ----------
          sort_to_front = []
          sort_to_back = []

          member_ofs.each do |member_of|
            # Note that member_of is a unique ruby object, not a string.
            collection = member_of.to_s

            if collections_of_interest.include?(collection)
              sort_to_front << collection
            else
              sort_to_back  << collection
            end
          end

          msg += "|#{(sort_to_front.sort! + sort_to_back.sort!).join(', ')}"

        rescue ActiveFedora::ObjectNotFoundError
          # This work was not found.
          msg += "|not found"

        rescue StandardError => ex
          # Something went wrong.  For example, "ActiveFedora::RecordInvalid: Validation failed: Embargo release date Must be a future date".
          # This will have happened at the call to work.save! and wouldn't have happened if no action had been taken, so actions_msg will be
          # the last string appended to msg, and actions_msg will already have been appended.
          caused_exceptions.add(id)
          exception_msg = "#{ex.class.name} #{ex.message}"
          msg += ", caused the exception #{exception_msg}"
        end

        puts("#{id}#{msg}") if msg.present?
      end

      unless fixed_creator_depts.empty?
        puts("---------- FIXED CREATOR DEPARTMENT ----------")

        fixed_creator_depts.to_a.sort.each do |fixed_creator_dept|
          puts(fixed_creator_dept.to_s)
        end
      end

      unless fixed_corp_names.empty?
        puts("---------- FIXED CORPORATE NAME ----------")

        fixed_corp_names.to_a.sort.each do |fixed_corp_name|
          puts(fixed_corp_name.to_s)
        end
      end

      unless misfiled_creator_depts.empty?
        puts("---------- CREATOR DEPARTMENT MOVED FROM CORPORATE NAME ----------")

        misfiled_creator_depts.to_a.sort.each do |misfiled_creator_dept|
          puts(misfiled_creator_dept.to_s)
        end
      end

      unless misfiled_corp_names.empty?
        puts("---------- CORPORATE NAME THAT SHOULD BE MANUALLY MOVED FROM CREATOR DEPARTMENT ----------")

        misfiled_corp_names.to_a.sort.each do |misfiled_corp_name|
          puts(misfiled_corp_name.to_s)
        end
      end

      unless unknown_creator_depts.to_a.sort.empty?
        puts("---------- UNKNOWN CREATOR DEPARTMENT ----------")

        unknown_creator_depts.each do |unknown_creator_dept|
          puts(unknown_creator_dept.to_s)
        end
      end

      unless unknown_corp_names.empty?
        puts("---------- UNKNOWN CORPORATE NAME ----------")

        unknown_corp_names.to_a.sort.each do |unknown_corp_name|
          puts(unknown_corp_name.to_s)
        end
      end

      unless caused_exceptions.empty?
        puts("---------- CAUSED AN EXCEPTION ----------")

        caused_exceptions.each do |caused_exception|
          puts(caused_exception.to_s)
        end
      end
    end
  end
end
# rubcop:enable Layout/LineLength
