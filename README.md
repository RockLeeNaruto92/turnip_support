# turnip-support
--------------------------------------------------------------------------------
**turnip-support** is the tool that support testing features of Rails applications.


## Table of contents:
--------------------------------------------------------------------------------

## Requirements
--------------------------------------------------------------------------------

For using **turnip-support**, the Rails application must be installed all below gems:
- [factory_girl](https://github.com/thoughtbot/factory_girl)
- [google_drive](https://github.com/gimite/google-drive-ruby)
- [turnip](https://github.com/jnicklas/turnip)
- [capybara](https://github.com/jnicklas/capybara)
- [capybara-screenshot](https://github.com/mattheworiordan/capybara-screenshot)
- [capybara-webkit](https://github.com/thoughtbot/capybara-webkit)

## Install
--------------------------------------------------------------------------------



## How to use
--------------------------------------------------------------------------------

### Test pattern spread sheet

First, you must create a test pattern spread sheet has template like below link: [Test pattern template](https://docs.google.com/spreadsheets/d/1es49-XMXjFLLKxtm1Te0kUTWxGGbbQPliaSq-6ku2RI/edit#gid=244159565)

I will show you the structure of the test case you must create:

The test case's structure has 3 main parts as below:
- Feature information part
- Initial data information part
- Test procedure and expectation result information part

Parts must be seperated by **1 blank line**.

<img src="./images/main_structure.png" alt="Main structure of test case" title="Main structure">


#### Feature information part

The feature information part contains first 3 lines. You must set value for 3 cells:
  - **B1** : Name of feature.
  - **B2** : Link of task.
  - **B3** : Status

<img src="./images/feature_structure.png" alt="Feature information structure" title="Feature information structure">

#### Initial data information part
The initial data information part must be start from line 5. The structure is:
  - Column **B** : Model name.
  - Column **D** : Object ID. This is the id that will be set to the object when creating object.
  - Column **E** ~ last column: Object's attributes. This informations will be set to object as attributes when creating object.

The objects list should be grouped by model name. When you want to create objects of a new model, please input to the start line below informations:
  - column **B**: The model name. Example: Company
  - column **E** ~ : The model attributes name you want to change.

<img src="./images/init_data_structure.png" alt="Initial data information structure" title="Initial data information">

In above sample, I want to:
  - create objects of model `Company` and custom `name` attribute of each object.
  - create object of model `Role` and custom `name` attribute of each object.
  - create object of model `AdminUser` and custom `loginid`, `password`, `password_confirmation`, `role_id` and `company_id` of each object. ...

#### Test procedures and expectation results information part
The test procedures and expectation results information part must be start from line that distances the initial data information part by 1 line.
  - This part can contains many procedures that are seperated by 1 blank line.

<img src="./images/procedures_structure.png" alt="procedures structure" title="Procedures structure">

  - The structure of each action part:
    - Column **A** : Procedure order number (ID).
    - Column **B** : Scenario name.
    - Column **C** : Branching ID.
    - Column **D** : Action name. See [All supported actions]().
    - Column **E** ~ last column: The params corresponding with each action.


  - The structure of each expectation result part:
    - Column **C** : Branching ID.
    - Column **D** : Expectation method name. See [All expection methods]()
    - Column **E** ~ last column: The params corresponding with each expectation method.
    - Column **I** : The default column of test result.
    - Column **J** : The default column of test image.

<img src="./images/each_proc_structure.png" alt="Each procedure structure" title="Each procedure information">
