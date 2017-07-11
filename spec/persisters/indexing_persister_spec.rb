# frozen_string_literal: true
require 'rails_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe IndexingPersister do
  let(:persister) { described_class.new(persister: Valkyrie::Persistence::Memory::Adapter.new.persister, index_persister: index_solr.persister) }
  let(:index_solr) { Valkyrie::Adapter.find(:index_solr) }
  it_behaves_like "a Valkyrie::Persister"

  it "can buffer into an index" do
    persister.buffer_into_index do |buffered_persister|
      buffered_persister.save(model: Book.new)
      expect(index_solr.query_service.find_all.to_a.length).to eq 0
    end
    expect(index_solr.query_service.find_all.to_a.length).to eq 1
  end

  it "can buffer deletes through index" do
    created = persister.save(model: Book.new)
    persister.buffer_into_index do |buffered_persister|
      another_one = persister.save(model: Book.new)
      buffered_persister.delete(model: created)
      buffered_persister.delete(model: another_one)
    end
    expect(index_solr.query_service.find_all.to_a.length).to eq 0
  end
end
