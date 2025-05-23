# Create costom pipeline agent under VNet
```
az deployment sub create -n deploymentName --location australiaeast --template-file ./main.bicep --parameters ./azuredeploy.orchard.parameters.json
```

```
az deployment sub create -n deploymentName --location australiaeast --template-file ./main.bicep --parameters ./azuredeploy.pallet.dev.parameters.json
```


# Delete agent once it is offline
```
az container delete -g rg-myorchard-dev-001 --name adoagent0 --yes
```