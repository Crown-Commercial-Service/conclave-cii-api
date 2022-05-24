require 'rails_helper'

describe 'Export' do
  it 'successful export job' do
    expect(Export.success).to eq(true)
  end

  it 'successful export job' do
    expect(Export.failed).to eq(false)
  end
end
