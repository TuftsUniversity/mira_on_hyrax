# frozen_string_literal: true
class CapstoneProject < Contribution
  self.attributes += [:degree]
  self.ignore_attributes += [:degree, :description]
  attr_accessor :degree
  validates :degree, presence: true

  protected

  def copy_attributes
    super
    @tufts_pdf.description = ["Submitted in partial fulfillment of the degree #{long_degree} at the Fletcher School of Law and Diplomacy."]
    @tufts_pdf.subject = [degree]
  end

  private

  def long_degree
    Qa::Authorities::Local.subauthority_for('fletcher_degrees').find(degree)['term']
  end

  def parent_collection
    'tufts:UA069.001.DO.UA015'
  end
end
