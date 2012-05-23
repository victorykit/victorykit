VictoryKit is a free and open source platform to run campaigns for social change.

To make sure you have the appropriate requirements:

	$ ./script/bootstrap

To make sure the tests pass run `rake` and to start the local server run `rails server`.

To be able to run the smoke tests:

	$ brew install chromedriver # [on Mac]

Then you can run the smoke tests with `rake spec:smoke`.
