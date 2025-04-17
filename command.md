# Create costom pipeline agent under VNet
```
az deployment group create -n deploymentName  -g rg-myorchard-dev-001 --template-file ./main.bicep --parameters ./azuredeploy.orchard.parameters.json
```


# Delete agent once it is offline
```
az container delete -g rg-myorchard-dev-001 --name adoagent0 --yes
```