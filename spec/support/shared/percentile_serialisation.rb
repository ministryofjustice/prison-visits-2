shared_examples_for 'percentile serialisable' do
  it 'has the require attributes' do
    expect(subject.as_json).to have_key(:date)
    expect(subject.as_json).to have_key(:ninety_fifth_percentile)
    expect(subject.as_json).to have_key(:median)
  end
end
