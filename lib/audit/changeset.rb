# A structure for tracking individual changes to a record.
Audit::Change = Struct.new(:attribute, :old_value, :new_value)

# A structure for tracking an atomic group of changes to a model.
class Audit::Changeset < Struct.new(:changes, :metadata)
  
  # Recreate a changeset given change data as generated by ActiveRecord.
  #
  # hsh - the Hash to convert to a Changeset. Recognizes two keys:
  #     "changes" - a Hash of changes as generated by ActiveRecord
  #     "metadata" - user-provided metadata regarding this change
  #
  # Examples:
  #
  #   Audit::Changeset.from_hash({"changes" => {'age' => [30, 31]}})
  #   # [<struct Audit::Changeset @attribute="age" @old_value=30 
  #   #  @new_value=31>]
  # 
  # Returns an Array of Changeset objects, one for each changed attribute
  def self.from_hash(hsh)
    changes = hsh["changes"].map do |k, v|
      attribute = k
      old_value = v.first
      new_value = v.last
      Audit::Change.new(attribute, old_value, new_value)
    end
    new(changes, hsh["metadata"])
  end
  
  # Recreate a changeset given one or more stored audit records.
  #
  # enum - an Array of change Hashes (see `from_hash` for details)
  # 
  # Returns an Array of Changeset objects, one for each atomic change
  def self.from_enumerable(enum)
    case enum
    when Hash
      from_hash(enum)
    when Array
      enum.map { |hsh| from_hash(hsh) }
    end
  end
  
end
