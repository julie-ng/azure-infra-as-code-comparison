import * as pulumi from "@pulumi/pulumi";
import * as resources from "@pulumi/azure-native/resources";
import * as azure_native from "@pulumi/azure-native";

// Configuration

const rgName = 'pulumi-sig-v2-rg';
const location = 'northeurope';
const galleryConfig = {
    name: 'pulumi_sig_v2',
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

console.log(sig);
