# create-asa-with-ssc

This project **hasn't been security audited** and should not be used in a production environment.

## Setup
To install all required packages, run: `pip install -r requirements`.

## Usage
There are a number of bash script files which execute the goal commands for you.

They should be run in the following order:
1. **startnet.sh**: Sets up private network
2. **createapp.sh**: Compiles the PyTeal files to TEAL and deploys the stateful smart contract 
3. **fundescrow.sh**: Send Algos to escrow account
4. **linkapptoescrow.sh**: Adds the escrow address to the application's global state
5. **createasa.sh**: Creates a new ASA from the escrow account
6. **fundasa.sh**: Receive 1 ASA that was created by the escrow account
7. **stopnet.sh**: Delete private network
