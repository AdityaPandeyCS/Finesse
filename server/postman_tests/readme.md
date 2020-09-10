Steps to run the test:
1. Get postman in the system.
2. Go to New button, choose Mock Server.
3. Mock the Server.
4. For POST - Account Creation - 
	Url - {{url}}/users
	Status Code - 201.
   For GET - Successful Login
   	Url - {{url}}/username=shilpa&password=pass123
    Status Code - 200
   For GET - Unauthorised User
    Url - {{url}}/username=shilpa&password=pass123
    Status Code - 401
   The above two GET request will be changed to Post.
5. Set the Environment by importing the environment json file.
6. Import the test collection, choose the environment and run it as tests.
7. Run as tests and all of them should pass.
