chai = require "chai"

chai.should()

foo = "Some string"

describe 'Sample', ->
    describe 'First test', ->
        it 'should just pass', ->
            foo.should.be.a('string')
            foo.should.equal('Some string')
