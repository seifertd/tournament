require 'active_record/validations'

# This class can be used as a container of form submitted values.  It
# includes an ActiveRecord errors object so that it is compatible with Rails form
# tag helpers and the highlighting of form fields that are in error.  It also
# mixes in ActiveRecord::Validations so all the validates_* methods are available.
#
# Example
# ----------------------------------
#   class MyObject < FormObject
#     attr_accessor :field1, :field2, :field3
#     validates_presence_of :field1
#     validates_length_of :field2, :within => (0..5)
#     validates_format_of :field3, :with => /^[0-9]+$/
#   end
#
#   form_data = MyObject.new
#   form_data.valid?                 <= returns false unless field1, field2, field3 are set appropriately
#
# In controller actions, you can create an instance of your object using the params hash:
#
#   @my_object = MyObject.new(params[:my_object]) 
#
# Instances of FormObject can be used by the form_for helper to generate
# form fields with fancy error highlighting.
class FormObject

  def initialize(attrs = {})
    unless attrs.nil?
      attrs.each do |name, value|
        self.send("#{name}=", value) if self.respond_to?("#{name}=".to_sym)
      end
    end
  end

  # Does nothing
  def save
  end

  # Does nothing
  def save!
  end

  # Always returns true
  def new_record?
    true
  end

  # Updates an attribute
  def update_attribute(name, value)
    self.send("#{name}=", value) if self.respond_to?("#{name}=".to_sym)
  end

  # Needed to display field specific error messages.  Override in subclass
  # if you don't want the attribute name capitalized when displaying 
  # a field error message.
  def self.human_attribute_name(attr_name)
    return attr_name.capitalize
  end

  # Add validation methods
  include ActiveRecord::Validations

  # Dynamically loads the class with the given name or fully qualified path.
  # Example class_get("Foo") or class_get("Bar::Baz::Bip")
  def self.class_get(class_name_or_path)
    klass = class_name_or_path.split(/::/).inject(Object) { |k, n| k.const_get(n) }
  end

end
