require 'rails_helper'
require export

describe 'Export' do
  it 'tests it' do
    expect(Export.success).to eq(true)
  end
end
