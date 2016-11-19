
## Generate Iroha File 

```
shell$ ruby ../examples/div.rb > ../examples/div.iroha
```

## Generate Verilog-HDL from Iroha File

```
shell$ iroha -v ../examples/div.iroha > src/div.v
```

## Make test.snr

```
shell$ cd ./src
shell$ gcc -o make_test_snr make_test_snr.c
shell$ ./make_test_snr > test.snr
```

## Create Vivado Project

```
Vivado > Tools > Run Tcl Script.. > ./test/div/vivado/create_project.tcl
```

## Run Simulation

```
Vivado > Run Simulation > Run Behavioral Simulation
```
