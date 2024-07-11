# frozen_string_literal: true
class GradScholarship < Contribution
  self.attributes += [:department]
  self.ignore_attributes += [:department]
  attr_accessor :department
  validates :department, presence: true

  self.attributes += [:advisor]
  self.ignore_attributes += [:advisor]
  attr_accessor :advisor
  validates :advisor, presence: true

  protected

  def copy_attributes
    super
    @tufts_pdf.subject = [department]
    @tufts_pdf.creator_department = [creator_dept]
  end

  private

  # TODO: copied from Honors Thesis, problally needs work in both places
  def creator_dept
    terms = Qa::Authorities::Local.subauthority_for('departments').all
    if department == terms.find { |t| t[:label] == department }
      term[:id]
    else
      'NEEDS FIXING'
    end
  end
end
