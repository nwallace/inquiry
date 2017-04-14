RSpec.shared_examples_for "a report value formatter" do

  it "implements #call to take 2 arguments" do
    view = double("the view").as_null_object
    record = double("the record").as_null_object
    subject.call(view, record)
  end
end
