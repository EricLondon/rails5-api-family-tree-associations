# Rail 5 API Family Tree Associations

```
# setup
rake db:create && rake db:migrate
rake people:create

# create people
rake people:create

# run server (puma)
rails s

# curl request
curl -XGET 'http://localhost:3000/api/people' | jq '.[0]'
{
  "id": 1,
  "first_name": "Eric",
  "last_name": "London",
  "maiden_name": null,
  "gender": "male",
  "depth": 0,
  "spouse_id": 2,
  "mother_id": 3,
  "father_id": 4,
  "children_ids": [
    5,
    6,
    7
  ],
  "sibling_ids": [
    8,
    9
  ]
}

# run RSpec tests
rspec
35 examples, 0 failures
```

Disclaimer: Sorry, relationships are binary and simplified in this example code.
