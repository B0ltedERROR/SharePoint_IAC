# Description
queries will be the core functionality to check my work as I work though this project. Thus I will begin with this section of the project first. I already have a primitive set of scripts that can accomplish this but it is AI code and I want to make it more modular. 

# Tasks
- [ ] [[Query Rework#json formatting|Make json formatting for outputs]]
- [ ] [[Query Rework#Re-Write Queries|Re-Write queries to be more modular]]
- [ ] [[Query Rework#Error Handling]]
- [ ] [[Query Rework#Documentation & Comments]]

## json Formatting
*json formatting that should will handle the following*:
* Site Collection Name r URL
* List Name
* List Permissions

I plan on expanding the json feature in the future but I'm not sure if I should have them all in one json document or multiple. I'm not super familiar with using json for code so I will differ to recommended.
## Re-Write Queries
The code that is in the initial commits are written almost exclusively by AI. I would like to re-write them by hand so I understand and own it. 

Also, I want the scripts to work together in a modular format. Each script will function independently but will assume certain environment when run. 
### Example
the script that will query a list will assume it is connected to a site already. 

Maybe in the future I will set the scripts up to be independent but I like having them separated as of this moment
## Error Handling
Make sure the scripts Tell you why they fail.
## Documentation & Comments
Self explanatory