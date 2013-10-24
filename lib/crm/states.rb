class CRM::States

  private 

  CODES = {
    'AL' => 'Alabama',
    'AK' => 'Alaska',
    'AZ' => 'Arizona',
    'AR' => 'Arkansas',
    'CA' => 'California',
    'CO' => 'Colorado',
    'CT' => 'Connecticut',
    'DE' => 'Delaware',
    'DC' => 'District of Columbia',
    'FL' => 'Florida',
    'GA' => 'Georgia',
    'HI' => 'Hawaii',
    'ID' => 'Idaho',
    'IL' => 'Illinois',
    'IN' => 'Indiana',
    'IA' => 'Iowa',
    'KS' => 'Kansas',
    'KY' => 'Kentucky',
    'LA' => 'Louisiana',
    'ME' => 'Maine',
    'MD' => 'Maryland',
    'MA' => 'Massachusetts',
    'MI' => 'Michigan',
    'MN' => 'Minnesota',
    'MS' => 'Mississippi',
    'MO' => 'Missouri',
    'MT' => 'Montana',
    'NE' => 'Nebraska',
    'NV' => 'Nevada',
    'NH' => 'New Hampshire',
    'NJ' => 'New Jersey',
    'NM' => 'New Mexico',
    'NY' => 'New York',
    'NC' => 'North Carolina',
    'ND' => 'North Dakota',
    'OH' => 'Ohio',
    'OK' => 'Oklahoma',
    'OR' => 'Oregon',
    'PA' => 'Pennsylvania',
    'RI' => 'Rhode Island',
    'SC' => 'South Carolina',
    'SD' => 'South Dakota',
    'TN' => 'Tennessee',
    'TX' => 'Texas',
    'UT' => 'Utah',
    'VT' => 'Vermont',
    'VA' => 'Virginia',
    'WA' => 'Washington',
    'WV' => 'West Virginia',
    'WI' => 'Wisconsin',
    'WY' => 'Wyoming',
    'AS' => 'American Samoa',
    'FM' => 'Federated States of Micronesia',
    'GU' => 'Guam',
    'MH' => 'Marshall Islands',
    'MP' => 'Northern Mariana Islands',
    'PW' => 'Palau',
    'PR' => 'Puerto Rico',
    'VI' => 'Virgin Islands',
    'AE' => 'Armed Forces Africa',
    'AA' => 'Armed Forces Americas',
    'AE' => 'Armed Forces Canada',
    'AE' => 'Armed Forces Europe',
    'AE' => 'Armed Forces Middle East',
    'AP' => 'Armed Forces Pacific',
    'AB' => 'Alberta',
    'BC' => 'British Columbia',
    'MB' => 'Manitoba',
    'NL' => 'Newfoundland and Labrador',
    'NB' => 'New Brunswick',
    'NS' => 'Nova Scotia',
    'ON' => 'Ontario',
    'QC' => 'Quebec',
    'PE' => 'Prince Edward Island',
    'SK' => 'Saskatchewan'
  }.freeze

  STATES = CODES.invert

  public

  def self.to_code(state)
    STATES[state]

  end

  def self.to_name(code = '')
    code = code || ''
    CODES[code.upcase]
  end

end
