#!/bin/bash -u

cancelscript(){ echo "$2" ;  exit $1 ; }

bearertoken="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
apiendpoint="https://api.cloudflare.com/client/v4/"
zonename="example.com"


# ========== begin of functions ==========

get_zoneid(){
 zoneid=$(curl -s -X GET ${apiendpoint}'zones?name='${zonename} -H "Authorization: Bearer ${bearertoken}" -H 'Content-Type: application/json' | jq -r '.result[0].id')
 test ${#zoneid} = 32 || cancelscript 1 "zoneid problem"
}

list_subdomain_all(){
 #GET zones/:zone_identifier/dns_records
 curl -s -X GET ${apiendpoint}zones/$zoneid/dns_records \
          -H "Authorization: Bearer ${bearertoken}" \
          -H 'Content-Type: application/json' | jq -r '.result[]|.name+" "+.type+" "+.content+" "+.id'
}



subdomain_create(){
curl -s -X POST ${apiendpoint}zones/$zoneid/dns_records \
         -H "Authorization: Bearer ${bearertoken}" \
         -H 'Content-Type: application/json' \
         --data "{\"type\":\"$1\",\"name\":\"$2\",\"content\":\"$3\",\"ttl\":$4,\"proxied\":false}" | jq '.success'
}

delete_subdomain(){
 # DELETE zones/:zone_identifier/dns_records/:identifier
 id=$1
 curl -s -X DELETE ${apiendpoint}zones/$zoneid/dns_records/$id \
          -H "Authorization: Bearer ${bearertoken}" \
          -H 'Content-Type: application/json' | jq . >>/tmp/del
}

# ========== end of functions ==========



test $# = 2 || cancelscript 1 "usage: $0 <subdomain> <ip>"
subdomain="$1"
ip="$2"

get_zoneid || cancelscript 2 "something went wrong with authentication"

# old subdomains will be deleted!!! (no updating)
list_subdomain_all |grep "^$subdomain\." >/dev/null
if test "$?" = 0; then
  # deleting of old existing subdomains
  list_subdomain_all |grep "^$subdomain\."| awk '{ print $NF }' |\
  while read id
  do
   delete_subdomain $id
  done 
fi

# Create subdomain with new content
subdomain_create A $subdomain $ip 120 




