package main

import (
    "log"
)

func main() {
    // parses the flag
    ParseFlag()

    // creates the config
    config := GetKubernetesConfig()

    // creates the client
    client := GetKubernetesClient(config)

    // changes the image
    // ...
}
