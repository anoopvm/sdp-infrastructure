import sys
from config_reader.config_reader import ConfigReader

ENVIRONMENT = sys.argv[1]
KEY = sys.argv[2]

def get_item():
    configReader = ConfigReader(ENVIRONMENT)

    catalog = {
    "region": configReader.get_region,
    "cluster_name": configReader.get_cluster_name,
    }
    
    if KEY not in catalog: 
        return "Wrong key"

    return catalog.get(KEY)()

if __name__ == "__main__":
    print(get_item(), end="")
    