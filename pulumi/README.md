# Azure Image Builder with Pulumi

I'm a Pulumi newbie, so this may not follow Best Practices. Feel free to make a suggestion by opening a GitHub Issue.

### 1. Clone Repo

Clone this code to your local machine

```bash
git clone https://github.com/julie-ng/azure-infra-as-code-comparison
```

and switch into this directory

```
cd pulumi
```

### 2. Initialize Pulumi and Dependencies

FYI I named my stack `poc` for proof of concept instead of `dev`.

```bash
pulumi stack init poc
npm install
```

### 3. Set default Azure Region

```bash
pulumi config set azure-native:location westeurope
```

### 4. Preview and Deploy

```bash
pulumi up
```

### 5. Clean up

```bash
pulumi destroy
```