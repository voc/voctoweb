module Types
  class SizeUnitType < Types::BaseEnum
    description "The unit a recording's size is expressed in"

    value 'MB', 'Megabytes'
    value 'GB', 'Gigabytes'
    value 'BYTE', 'Bytes'
  end
end
