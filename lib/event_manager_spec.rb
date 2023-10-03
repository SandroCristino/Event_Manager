require 'rspec'
require_relative 'event_manager'

describe 'Sort Phone Test' do
    describe 'test general output' do

        it 'Less than 10, return nil' do
            expect(sort_phone(11111111)).to eq(nil)
        end
        it 'More than 11, return nil' do
            expect(sort_phone(111111111111)).to eq(nil)
        end
        it '11 digits and first number is 1, trim first number' do
            expect(sort_phone(12345678909)).to eq(2345678909)
        end
        it '11 digits and first number is not 1, return nil' do
            expect(sort_phone(51111111111)).to eq(nil)
        end 
        it '10 digits is good number' do
            expect(sort_phone(1234567890)).to eq(1234567890)
        end
    end
end


