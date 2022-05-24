require 'rails_helper'

describe 'Export' do
  it 'successful export job' do
    expect(Export.success).to eq(true)
  end

  it 'failed export job' do
    expect(Export.failed).to eq(false)
  end

  it 'returns string container name' do
    expect(Export.azure_container_name).to be_a String
  end
end
