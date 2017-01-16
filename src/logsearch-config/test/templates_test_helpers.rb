def verify_collection(description, collectionExpected, collectionActual, methodName)
  
  it "#{description}" do
    expect(collectionActual.size).to eql(collectionExpected.size)
    collectionExpected.each_with_index do |item, index|
      expect(collectionActual[index].send(methodName)).to eql(item.send(methodName))
    end
  end

end
