# cloudflare-dns-cli.sh
Minimalistic script to create new dns records and existing records with the same name

##configuration:
* set bearertoken variable
* set zonename variable (= your domain name)

Be carefull: old recordnames will be overwritten without further inquiry

##Usage:
 ./cloudflare-cli.sh <subdomain> <ip>

 ./cloudflare-cli.sh www 12.34.56.78
 true

