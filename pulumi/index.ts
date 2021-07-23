import * as pulumi from "@pulumi/pulumi";
import * as resources from "@pulumi/azure-native/resources";
import * as azure_native from "@pulumi/azure-native";

// Configuration

const rgName = 'azure-sig-pulumi-rg';
const location = 'westeurope';
const galleryConfig = {
    name: 'pulumi_sig_test',
    description: 'Testing Pulumi again'
};

// Resource Group
// --------------

// Create an Azure Resource Group
const resourceGroup = new resources.ResourceGroup(rgName);

// Shared Gallery
// --------------
const sig = new azure_native.compute.Gallery("gallery", {
    description: galleryConfig.description,
    galleryName: galleryConfig.name,
    location: location,
    resourceGroupName: rgName
});

// console.log(sig);
