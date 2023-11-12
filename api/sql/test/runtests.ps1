# CURRENTLY NOT WORKING




# write a powerhsell script to run all the tests, it should run ..\schema.sql then the test and then rerun the schema and proced to the next test
# the command to execute the sql is
# wrangler d1 execute "timesheets" --local --file "<path>"

# Define the path to the schema file
$schemaPath = "..\schema.sql"

# Define the list of test files to run
$testFiles = Get-ChildItem -Path ".\pass\", ".\fail\" -Recurse -Include *.sql

# Loop through each test file and run the schema and test
foreach ($testFile in $testFiles) {
    # Run the schema
    & wrangler d1 execute "timesheets" --local --file $schemaPath

    # Run the test
    $testOutput = & wrangler d1 execute "timesheets" --local --file $testFile.FullName *>&1

    # Check if the output contains the error tag
    if ($testOutput -match "X \[ERROR\]") {
        if ($testFile.Directory.Name -eq "fail") {
            Write-Host "[P] Test failed as expected: $($testFile.Name)"
        } else {
            Write-Host "[F] Test failed: $($testFile.Name)"
            exit 1
        }
    } else {
        if ($testFile.Directory.Name -eq "fail") {
            Write-Host "[F] Test did not fail as expected: $($testFile.Name)"
            exit 1
        } else {
            Write-Host "[P] Test succeeded: $($testFile.Name)"
        }
    }
}
