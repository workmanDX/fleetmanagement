# Sitetracker : Fleet Management

## Installing Fleet Management using a Developer Edition Org or a Trailhead Playground

Make sure to start from a brand-new environment to avoid conflicts with previous work you may have done.

1. Clone this repository:

    ```
    git clone https://github.com/workmanDX/fleetmanagement.git
    cd sitetracker
    ```

1. Authorize your Trailhead Playground or Developer org and provide it with an alias (**mydevorg** in the command below):

    ```
    sfdx auth:web:login -s -a mydevorg
    ```

1. Deploy the App with these steps:

    1. Run this command in a terminal to deploy the app.

        ```
        sfdx force:source:deploy -p force-app
        ```

    1. Assign the **Fleet_Management** permission set to the default user.

        ```
        sfdx force:user:permset:assign -n Fleet_Management
        ```

    1. Import some sample data.

        ```
        sfdx force:data:tree:import -p ./data/sample-data-plan.json
        ```

    1. If your org isn't already open, open it now:

        ```
        sfdx force:org:open -u mydevorg
        ```

    1. In App Launcher, select the **Fleet Management** app.
