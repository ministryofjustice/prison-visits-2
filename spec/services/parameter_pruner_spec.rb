require 'rails_helper'

RSpec.describe ParameterPruner do
  it 'removes hashes with blank values' do
    input = { 'foo' => '', 'bar' => 'baz' }
    output = { 'bar' => 'baz' }
    expect(subject.prune(input)).to eq(output)
  end

  it 'returns an empty hash at the top level' do
    input = { 'foo' => '', 'bar' => '' }
    output = {}
    expect(subject.prune(input)).to eq(output)
  end

  it 'removes hashes that are themselves empty' do
    input = {
      'name' => 'Bob',
      'date_of_birth' => { 'day' => '', 'month' => '', 'year' => '' }
    }
    output = { 'name' => 'Bob' }
    expect(subject.prune(input)).to eq(output)
  end

  it 'prunes arrays' do
    input = [
      {
        'name' => 'Bob',
        'date_of_birth' => { 'day' => '', 'month' => '', 'year' => '' }
      },
      {
        'name' => '',
        'date_of_birth' => { 'day' => '', 'month' => '', 'year' => '' }
      },
      {
        'name' => '',
        'date_of_birth' => { 'day' => '', 'month' => '', 'year' => '' }
      }
    ]
    output = [{ 'name' => 'Bob' }]
    expect(subject.prune(input)).to eq(output)
  end
end
