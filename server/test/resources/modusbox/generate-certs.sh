#!/bin/bash

cat <<EOF > ca-config.json
{
  "signing": {
      "default": {
          "expiry": "87600h",
          "usages": [
            "signing",
            "key encipherment",
            "client auth"
           ],
           "signature_algorithm": "SHA256withRSA"
      }
  }
}
EOF

cat <<EOF |  cfssl genkey -config ca-config.json -initca - | cfssljson -bare ca -
{
        "hosts": [],
        "names": [
            {
                "CN": "ca.connection-manager.dev.modusbox.com",
                "O": "Modusbox",
                "OU": "Engineering",
                "C": "US",
                "ST": "WA",
                "L": "Seattle"
            }
        ],
        "key": {
            "size": 4096,
            "algo": "rsa"
        }
}
EOF


cat <<EOF | cfssl genkey -loglevel 0 -config ca-config.json -ca ca.pem -ca-key ca-key.pem - | cfssljson -bare hub-tls-client -
{
    "hosts": [
      "hub1.dev.modusbox.com",
      "hub2.dev.modusbox.com",
      "163.10.5.24",
      "163.10.5.21",
      "connection-manager-admin@hub.dev.modusbox.com"
     ],
     "key": {
       "algo": "rsa",
       "size": 4096
     },
     "CN": "hub.dev.modusbox.com",
     "names": [
         {
            "emailAddress": "connection-manager-admin@hub.dev.modusbox.com",
            "O": "Modusbox",
            "OU": "Engineering",
            "C": "US",
            "ST": "WA",
            "L": "Seattle"
         }
     ]
}
EOF

cat <<EOF | cfssl genkey -loglevel 0 -config ca-config.json -ca ca.pem -ca-key ca-key.pem - | cfssljson -bare hub-tls-client-2048 -
{
    "hosts": [
      "hub1.dev.modusbox.com",
      "hub2.dev.modusbox.com",
      "163.10.5.24",
      "163.10.5.21",
      "connection-manager-admin@hub.dev.modusbox.com"
     ],
     "key": {
       "algo": "rsa",
       "size": 2048
     },
     "CN": "hub.dev.modusbox.com",
     "names": [
         {
            "emailAddress": "connection-manager-admin@hub.dev.modusbox.com",
            "O": "Modusbox",
            "OU": "Engineering",
            "C": "US",
            "ST": "WA",
            "L": "Seattle"
         }
     ]
}
EOF



cfssl sign -loglevel 0 \
-ca ca.pem -ca-key ca-key.pem -config=ca-config.json hub-tls-client.csr | cfssljson -bare hub-tls-client

