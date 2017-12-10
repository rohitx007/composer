ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1-unstable.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1-unstable.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data-unstable"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
export FABRIC_VERSION=hlfv11
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:unstable
docker tag hyperledger/composer-playground:unstable hyperledger/composer-playground:latest

# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d

# manually create the card store
docker exec composer mkdir /home/composer/.composer

# build the card store locally first
rm -fr /tmp/onelinecard
mkdir /tmp/onelinecard
mkdir /tmp/onelinecard/cards
mkdir /tmp/onelinecard/client-data
mkdir /tmp/onelinecard/cards/PeerAdmin@hlfv1
mkdir /tmp/onelinecard/client-data/PeerAdmin@hlfv1
mkdir /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials

# copy the various material into the local card store
cd fabric-dev-servers/fabric-scripts/hlfv1/composer
cp creds/* /tmp/onelinecard/client-data/PeerAdmin@hlfv1
cp crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/Admin@org1.example.com-cert.pem /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials/certificate
cp crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/114aab0e76bf0c78308f89efc4b8c9423e31568da0c340ca187a9b17aa9a4457_sk /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials/privateKey
echo '{"version":1,"userName":"PeerAdmin","roles":["PeerAdmin", "ChannelAdmin"]}' > /tmp/onelinecard/cards/PeerAdmin@hlfv1/metadata.json
echo '{
    "type": "hlfv1",
    "name": "hlfv1",
    "orderers": [
       { "url" : "grpc://orderer.example.com:7050" }
    ],
    "ca": { "url": "http://ca.org1.example.com:7054",
            "name": "ca.org1.example.com"
    },
    "peers": [
        {
            "requestURL": "grpc://peer0.org1.example.com:7051",
            "eventURL": "grpc://peer0.org1.example.com:7053"
        }
    ],
    "channel": "composerchannel",
    "mspID": "Org1MSP",
    "timeout": 300
}' > /tmp/onelinecard/cards/PeerAdmin@hlfv1/connection.json

# transfer the local card store into the container
cd /tmp/onelinecard
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer
rm -fr /tmp/onelinecard

cd "${WORKDIR}"

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� ԛ,Z �=�r��r�Mr�A�IJ��e������I HQ^9��%R�M�d�x����4.�(E��	�*?���?�!ߑ�kf 	R�(���U6��FOϥ{��{@�T��
)f�k�(��a�i�������� �!�g4.p�O
Q^|�G>��RL��p|L��O wO��
��@�'��4�f�Y��Q8C����X��F֙� {�a �ׄ�����j�>������R��&.k���ґ�DVdPXR�kZ�� �6�Mn������V�֪�]��ѹ�,���9���2_{,�ЀuKSB*:��ǫ!r�m�ǥ��P�����K� �;'S������w�T�gdiU�n��������	���$D!��?.F���_<�}���:�[�m��� ��(*�P5��Z��2)Wv>V�k�T����,��'����[�nBYx�,��o
��?�}2�_U�yi)�����?n�"������d��)l̧�&�ǎ���/p����X���)�߅J���S�4�z�#�x���>ɓl H"G�D�����% Kd������n�z����pa.��^��l�Һ�_���.�@����1Z�N��gS�3>́�i���n�;mt]���w-��E��c��Y�k�i�q�%=b�ᠩ9�9\�Z:)i9N�ފDpM˭���zH嘦n�����+�t��iю:�����56m[�b�B!!�yUm�j�wK��\�uSi+-����]2�6a����=�n��t5-���!�v�ջ "MG ��)�r<��4�"CE��� M�I(�!N��7�4Լм*>,��T���k5�g�����\-��on9��u=M��3�?��ON��Eb���������<���P�N:���:��
,�1�.D�rC3��������|��d�~{��J��� �i����&xlA�~�,��4��@J��.n�І����� �$��`#���$T�@���������օ[/�N��K�VP� � �^�Q������ ڠ�0��y(t�FL��?���lƽ�ncX#�d�vL:��|���2��0p�EfڦN��`{\g}�<�݉dz�H`|}ta
�8f���Kj'VH��'��J��Ї憎���(�9�D��A�Hq@��)-`R��,�}�����	~t��:y�Y�������2m>�w����3�E�H��Ǐk0��:�� ԱS�~�r�8��������a<t�9~9��¨���;�c�)�?YH�v�K���cR<������S�4�������h���9A�I1��?���,<;)=:��3�́�L��5f�:�c7g��g���E`�����3�|y��	S��W>VR��Au�W�������ve�1X[� _������FnVN�󩏇�r%�_|q~5��}�wh6p9�F��i��7�x㟓�%0��6�W#�F7���'��:^��%��u~+U�\�X�2����\��M㝗�s��R��k]{z���>��B�kxǅ^��������w`uj���>��GBm�Y�El�C`��:�X��'�%�JO�%c2���:��+^dx�]�_���hvrY`v|a;~�5�86��O��2ɑ�<��,�O��'�<���������WM巸_�l��ˉH���x��u*hXf�qa^
s �޸��M�E��!��������t g���&����<�]ܿ�3Ͼ��{ft;@3���:��vhh�`��c�C��}�u�S��`�������s��2�{0{���3�*�������Q>&ļ�[��"��?ϥ�Y�?<��$�\���h4���[L�3�7�[��e���Z����N�f�Bgd�G�u�t�͵#�S;ۿ�t�u~���(���D�l��:4�Gi_�]�,Rc�mu �1��ӆ|#bx��2�J��C��[� Ԙ(!�#��3f�NȄE�o ���
�I����gV?h�?F�C~h���a���h��Gԓ�ԧ0�l!��u;�s�q�p��*c�f�Oġ���b��b�!Ş�a����6ci������K!�������|��)�������?��Dk.P��~����.�4{tJ���<f�@��`���Y[t�a.,��W�ga+�8��L���ɑ�*-�>����W���R����||������������y��ϰI����o�{y&�@��6� $q#?�"�"	��0��g�Wì�@DjX
�+��6e�`�Sy�*��K�~(�j�{�	έ��O�$��\kӲ��6<�N���q71C�fmPG�O48�^#r� �"��fj��	90�t�����[�64fH�㳈�J�f-x��	��n���|���&팵�x�T��'�D�t!��9��?�/���~���%&�`@��O:�;����c��.e�c��������V$B-�i;[qN�XpEQ?�4H��ǮL>#�#�6�&F������+��*Ƙ����v����V�co�oз�#���-D�!�D�Z/��`VE>F���Ӥ~w�P9���A����(�1W�3�9(��j��n�x����7�~�1�#�К2�&4�HS#�Cqm���]���J�X���#�"��"�u�c���7��fc3��X�T�EQ^�m��S�"�@~3u>a���h��T�\]׶�4Ⱥ�	)D*�]ԡ��B�'б2!���t��@��4�E�U���)O�G��u�K!�# �mM���P�&�)���HyK��;D�mg��0�e�3�CSf=����OW#~2ȴ�9^)%�E`���i����9a��zW�o���Y��$�H�/y>��'H�2�s!���-� �ږ��r�0��WL��L��63����7�V>���������bT��<� F�������b`^���sN�#?OE�<�V�n;5M =�`T���ː`K��b�2�6f��N7Pe��@p�7>D�2tr]~�nh����1��n�v�K����q��6W�b~��X`�gW/w����+��G��N�{q�X��B��ފT����.��S��<���Gw���ڸk��(���i������)1O=���Ym�	���/�&�?I���Y0��=�����?���������`�vb���5��9E��fC�^L�F�!*��D�QO�`D"�Ę��'��ń�H����$�7%i�߿g��=3IxE^�g��nW''��YaV~`��lo+O~\e��iئ�hng�V��Y�`����?}7N�߾���e~G���Z���l���w���7��Gv^-{�W�b��qʈd�p�������x��3����?�p?��;���D1�R�/�p����wic����煸��B���1n�����},v8��q54�=�2u�(��`a������Zd�z��� �>��Rv�%��h����1ʼ�܄6�v����x�@2���i���\����F!�O�NS)YI5�^>)7�e�����}5���ͷq�̴�R/�<��'��S.�q{�EfS��9��e��B��p�����f������V=�w��7.<ʜgO�W�TӇ�NK��J'��ű�y���o=���%�'��m�U��O*�i]��w�2�p
ՌPl�7�:S1{;-�X�*��i^(T��~5/��SZ���G��z�d�R���a������.2�8һT��[�6<:9S:R���9*$K^����FMȺ��I��H:�o����L���(������<�d<F�"�(�u�ܹ��)�ի�<��B.����Ą���R)�{/�#sy9�s7wϓ%>�>�T���Y��V;�=:��X��Q��&�c쵏�z��8���n�M�
��I���,V�y���c'b��k�vO���^A�\`n�t/���Jd�w�i�@�z�\Hʍ͌|*˅�Mz��{�v!�+����d>�xoX�vo�����������
��F����-��gxS2ה�Z*_J��n)��He����c$n�t������t^B��;L���H3߬H�1�S|�Wͬ���L�WH���{��aa� rZ?%&�gj�V���t�g��)b�^]]�#���=�h�iF��tL@�ӽ~�㽻!C[��y�����1��4���f��F���yuw����k�}	���ԋ���(V �������{���1-}���'˷���׃Ć*������%wM-�����S�d_>�*�[T�����M#墼[2��M��,����]���B�}������C����u�|ʈ��Z�T��RVGR�pG�i�T�Ȩ��[�� 9������N�C�,��B�)3���w�k�����abv�hc��c��|��$Ŗ��B�?���Mb����y�$f^���Eb����y$f^����=b����y�#f�o���=�<�o�������[|5�ϭ��/�ɷ��	���e��B ��Ւ{�T��˶{���oץ����K�%%]j��Y�l���7���y��م��S��Ϟd�R���[�0[N�LS6����^��1��!��=[�s���Ѭ�aZnno�Iξ�����/���M�p��W�g�̻���I"_��"�H�ݾE������ꆁ��L�lPFt]�a�ɲ?H��y�z�byY[`��7#��05v��@ݷ�6B ���ьY�A�zGW�@�I�J�Y��0U�r��d)��Q��%N��< �(ҟ�� @��@����ZZ~�m�l��:���5-2���t�GSP���w��/�@�PVF?F�cڎ����ڹ��<��W1�l~�%<���o������V�dz�C/��_3�%r��i�WI��{�B�$�Ms����L'�@�t-���Q�]Wa 
�ۭ�G^`ԃ}�2y�j����ѣ�ӡ�&/������AR��r,٘v���>iۦ��1��3�*t՗�g��2��jؽX��~��A� 64l��^Ȥ�tRx�L�[���ʀ�:�lP�c��=r�}8�&�y,M�W�ǁ<�*��%�d���;��hㄷ�F�V`//Ã��{��:�UwO���7������V��؉�)�Ic�N�T��S��EɎ�'N�N�Dz�@H3�� �7�݌`��,�° 6#�7���k���'���z��[���K%����;�{��<y��r1�ɓ��x�idx���v&S�A�B6�9 ���	��W��D���f��xtc�⶛��3M���I1�.H9�·ە����d
�¹AFr��������jl��d�gk�dirN��昋O�7�_�jg:+�h����1��)\V�.MJ5�"b�k4�抱� "ēxt�J��O}��u�Wv�R1�x��td?$|�k�S �+���t]��"I��
}�����+F��F�:�?j��{�n�?�\��5ٓi�u`�H�#�?~�F�ePv���!��A��S{
0��1� ^����˦���y,ݍdk�4m�j��;ėeu�^�� �(�1��z=���5CG�Ens�5��Ӷ�y+A��}���� �VE�|�<_y8MO����95-[��{c �a(������w~���(�!�S�j���]�����M	m=B1L/����?���6�$�����[y��x<�E�'�������_�?�������K�����������7��k����}���o��|������yz]C�$u��$��t\Q����+�dJ%�x"%+q"�&�dL&*�͐�J��$���ΐJ|�H9� ��_�y�s?M�?����N�s��O�w����X��b�z{}u���ۑﾽ�E�ߊ��-�"�����c_�ȿߏ|q?�������#�����k�\���5�(W��ts�6���JY'M�a�F�N���J�Vc�f	�����G�X��#0]�p_�m?3�c���sAl��۞�VsNl^^ҤpҞ'5J8�H m�Ղ4L(��.���m�6E�.8��5�s�l�5w���<4�B���h���9�����b_��]�<�'�ܜ���K��D�E8r�9m�[�;N^CyX���O�j{�+lTc�I$���=~yP\0C�tڏ��סlG<m��bi��|����t�R��ꅽ�����\y� N����7� #՗�=!sX��z�J�
Q�s���FG�E0>��cL���A�E7sӡ�����3�Z�㵚��l�4eqZ����H�J�C�S����H�j���(�G�^|��4�`� d���br5�'6Ӗ8M��y&mP�=��LN��q"k)]��<(M�,�?2�M*)�Z��]��4=�I�2��~��V�	�C����|��.��;��;���=��M��F�&#��O*Y��K	��B���nv$�s�$��r'fԳ��Y�C~)bg��s����Kʞ�=L
�k�ʞ뉞�S `P�p�NL.\O�`��9�����t��S�i|ΐ��Q��z���ݓ�1��f�U ���)i���->��5�D��J�z4!Hs�R��%/?�/�E��:&���ҙDL�2M�<[UH�H*}�t�nJ�N�_;u�?%�0Kd*6�r��J�F9�i�Nn�ni}A��b��Y�>*��k�R��C=��4+�nSb=V�z��p�N��,��.������#�Dv"�������ux{������߫���_�DpC�;�[���,\�CO���w�#o�|-����;Q/_�;��z��{���A�#�ЖW#�D^
p^���[��"�{'�o��B�\��~���<��O�G~p?����0�/.ee�%`e�������UDKg�LkQ�R����랑����e~����ϒ�t�ur.ca9��$�8v�Y ���\�u��0��\�Us8�c]��Ɂ���s�
d�a�*JK�EF�zgV�C`�����(Ԙ%�+���l��ǎ�je��Dkv�d�D�2��r���cՎ~��&��PV��8���N��ҽ��h�+j:?.�D���D��r�4��H,Km�#`:Fks�;��հ>��4d����E���ZMg��$sˡ��QM����^�p/����y
8�|��s�ߢ��`I`k�R+h��h�֏�Šz��	��������
� �%Gk�p�t�PB4A��Uc{D�ό�~�P�:�Q�ş�./��d�������߹�h�PQ�E��.Fy�9�	�R�K�*�6�חg����������/m*ȹ%}�+�����#P�8bE..��E��[����l� �w�� �9<�J>�cץw��1���m�y@���1��&±�rY�/O��[��=�$�Z����%Nˇ�65�r)�7h��Xm-s6�1��jw����!����W�QZϞ��2�l�O�e����p�h�U�9WQ�
4���r�dko�Zk8(S�U��+�g�ћ�Z�����F2�S�P���Q�  �5�O���{����ΡZ,�bSs�FjVĘx�w��iG�
�z]��b"�/�{�lA�����52}bP�1R��(3]\�?�N�W��DY��d�$By6��GGzj*�����pF+qd�v���iO��s��h`�݂�&�u�`|a�������c�0�Cu�(Xx�{�@iG�Z�{��YI�Q�*u`��\f��c�1���^�L�:����rO�Ag�r�b�QNͦy��Ǎez:ӱ��?���%���j���i|�������uk�Դ�,Z�Q{'*9�l %����y����H3��(R5y>%(�EwD��(3�ҳ!�0HJ%��Xa2z3*1NcގM���Lrnז�e�B�t��L���"b
���J/�(�-�>�oF��nA!2��^&�R��\(Ё���uղ'�{*��3>�u��n�:������{�װW-�0�,��/0���7��y+��v��ӧĻO��A�oao�<��(/�f�U�r�����<�8�]q}=��+z��+Q0N`�
���Gmh& �B��Xf�χ�/�~��-y�s:AC����z����y�C+�D�,ՊP�ػ��S�(yt<w-�������y���ОȞ_��=���Œ�3���/��܌�/�F��Տ��i��C��{=�^�t�Z�CVqE�S�>���A��Y�)�d�ci"U�7�@4.�k*4�3X���#k�<�&Di�ͻ����>�������o��xoXת�Z˰�b�,����nO�6t̺^��a�Y�����r ]����[���\ n���kh�M!u�5	�_oG��b��5(�!�[K�9Ƃ���� �)B� �OTT��Z�L���
�}Sћ@��a�����}�F8��)
y�l�P��	��6n�ͩ��#�,�)h�����+Sw���� d��|e��l�LP�$d	��C��-$���O�����	��L���pB�m,x�J�G2ꝩ�9FF��h�O���Y�߇�A�YȺ`�F�b��OZa=� @�0��'�m+bMn�ϱd���y����5�	�������;f��P���:�Z'� 	L�ʸ�=O�+& u��Du��d��u@8����jR5�+9���\{"�1v��_!�ѕ�º���L�nߜ�k���Y���}�T���G?� �4���.�LL�B��5�E��ӑ������m*���Sk�<��,_e�&�3xÑ���,��ġ��5h��>�E�a����В���9��eE�R^]�T�xv��"
��&H��@?Y�[̜ `��8�w%k�Ȳu�p݌�q5�����^27\3N���]�T*��/���oC=�tý�J����p_b�����@r�N�*�`��`ɽ����yo��h��1��JCh剘H��t$��#"b(B%\�e��^�>NZ���F
ԳF��4���!h2
��!�@(�&x�X�(�ܲa�١4ׇ��
 ر:��@��P�s��4�9����8O�l��2�;V~��ze�F81��:�!�W'�d�n)�&��h��*@�^ř4.0��U��/�l4o�x���i?(|����e�~�!��~�Fd�M���f��V�tv5 A�ވ@:���L���(F�:ʃ����H�!b�B�X!@������|uŚ���n�׵��	2�(���X�\q���<O5�h���n� 'p���-(m�Dh
�b�݂W<�a�ڎ9x|c]S~��qC����)$8oG�W���V�75��^q�ok����Ά8���K��S)2������������?$?�0�z��J��\ry%
�����0sh���g���:�=���02��jw�[�y8��`��ru��L[��wQ)xx��KW�|�j=/��p�g�G"IE�ũ�LJ�L�2�*Qq5N���^���%�#$�����T���$�D"�JdR�QpрA��ܾ#l�a�P��h�}������/�� '�n�֫�b˄����gId$9II�,��XJ��Tݘ��$)�Ld�T,�L�qIV`!)F2�Q)����
(��������*nx��ۆjh�={��ݿjo�)��S���a1ȸm]������P�W�jd[��\`u�+su�t\��K�!Wz���T;?��2Ͳu��xC�U����o�o�X����V�%Y����s΅�:��KB�ʳ�C�c�冑�4�����@Pރٱwg��؎j&�W�Z�nT���TF�tv�։�wP�����]7nAl�Ϣ�?\kٞq��݂�p �ֺ9B���$����͔�Q��g+u"y�/珫W�@t�>[��r�®r�4�rL3���P8��l���ӑ>ߏF��ut&M����ӭYa�D%a�� #/�=
�����D[K�mc+�P�Pi��J9��˜ت�л�>�/��W�F:���L Յ^���Y���e5	�e"G�>YZ���=Κ�n�e.ȟ�4���������+�>�I'^(�~[9
Sz���L>�I���C���$�x�(��yD ��:N=?�_A���vd�N��|�z���l�B�u���xu0�u�-x�dF>vl��^��ٍb��l�8ĿnaG,sܬ�@��Sa��P�[Eǰ�϶t|>�oW�y���"�d�L$�������_��<�����-u\u�W�?��~��V�>�gx�u�?N�w��W��7E������}��ӿmX]�:a��[xnc������;�+�W���Dl��SP�����n�������a��}n��_��B�������<wh�<��y�y�h�l�~��+��Q[�����ޕu'���{~�w�Z-�pq�:L*"(ܜ�,N��(��Ӥ�U]ڝT�t��WYY�T+f�{?�~+AU�/8���eшa��$�^DP~�>ǰ��,�F�OP�1$zh^E���/��O��F�?Acw�����J�����������Z�d�'�tm���=ҚXѾ�ӜS��qH��Y8:ON��r�s�ik�=�e/�0�ܛ���M�� _;�>���)k'Kl�c,'�r~�W�z0���!���uO�(�fn���Z�����]��ǣ	�?��������lHݯ�U<����q��U�	����������f6������_?����(���5��mR���S���v�ǘ����J� �ZŽA��z �����}��4�h�?���D�CU��O�Wҿ���U �ꄫ:����O��{0�	�����w������[�5��������� ������Oa���8��
������7�J}o�`Y����\/���]���e-���&�/���m����������{�����o��(��7�J�|~�����'�2p���Ze-�T�a��������~��T����bK�u�s�3��q���E���'���;���R���ϗ�O�G�>�n��3���\>Z���o�O���O�2K/��v-v{�o�>��a�^��\��r��șc�T�J6}h�;R�_�����Jw��m�vOS���|w��G[�s�:��.�dĈ4v���߭h������ ��� 
%�z ��s�F�?��kC��R��F#����'������O���O�����W���$���� ��s�F���g��O�W�F������h����������u���W�o�q�T�s>�qU5�Ɉ�S�7��w�_����_l}�L'M�{[�����z��i�s?+�:�Fcq��{/7��b"�KuX}Zqv\�a�VAA�L,9���{S:"�s���P��nǴ�kr�d둿����������;����l闂hJ�����������7��pl(^%�W�Jp�uZ�W4��4��+m���vWA���'��:tq�pmR&����7i)���/ťm����`���F�?���@�U��Ux��������?��k��}���_	���A�a�QX�4P,�,�R�hHz���>��M�4��磄O���pG���	��(��5����Y9p��9�Q���i$K3�t(��n�s-�T��m�����%��`��ܞ����ɋ�r8Y�/��.2_��jv'�.6[B��#�Y,'�dF�����k�T�͏��Yq����M8�!��>�|��k��֊&�����C#��jC������j�~3>!������ï�Gݐ��*�N�i��&rt���8�^��]:�ҧ�0K�/�O�P���0�~��>���]�(�$*��ųC�����Rɞ��˺zѱe��MA�?�2��d��
��[ь���oMh��������7�	�_��U`���`���������h�:���0w���@�U����S^�_L���d�y7<nf��,ar"��w��������^��;�q�\���g� @���w  ��هw \��ߝ��%�P�"�K ^��7NQJ�m�o�yJ�e��W��9DȨ�ij�P���4�qW,}���ɀQg��Jﻞt��\՛qXrz��,c�/��1�i��%�r��^�x���;B�	W?pb�#\�'�/�pa�w�^;�G��=M�c�2?�C�� �²�lH��L'm5���y�0��;[a�̔���ED�=���M>�Ɇ��U�]���~���\�	I2�$e�ER:��'�.[|",C���к�ͯ�M���i�צl�kO/+���#�ًM��@������ǟ���E�����`�����&�?�>����%���!ӯ����4��V������������7�	����P���8ף)��<�dQ&pIu9�ui��Bei6$\/���8�\H2!��n���&��G�(�*����u��qU*;��o��#T��	/�%� �~B�����A�_�ͱ��v�<��fI.�t�t��ﱧV1F�B�Mq�Q\^���2�Q�&ׂ#G����l�ӃȑN�:QbӁ�߷�	�?F>���?������P����x���$���@#�������_E����`�@�{��_7���]���*B���߾�/������G��I�U����[�������v��.A[�^����jm���e-����˸�@~f���=�gf�o�l�g��bjLǹ;��ǝj�A^���Y�,Xwu6-m�N�>K��tI崴@�c�/����t¬�v4wU^����$��8��+$V7%ӂјvH�ҍuiY�@��.r��J�Y�gۋ�7�s���A8�0�
u��m��W�����ZK�>�#]�x?��l��!��jЈ(�{Ϛ�$�5�ڋ��b$�
���.&�Iڱ��J��	�N*�\Y)4�9��l��F.�\D�cN�n��F�eW�&迫ڃ�kB5��wo*��n����1�_kB����MC����o��*���7���7��A�}����� 	���[�5����_*���/�
�4��?��%��U �!��!�������o�_������~iݯ�U<����%h��(z��	��*P�?��c�n �����p�w]���!�f �����؃�������5���v�������Y��U�*����
�*�?@��?��G8~
���]��?*B�l�����[�5��������� �������(�����J ��� ��� ��5�?����?��k�C��64��!�j4��?� !��@��?@��?����?���Y��] ����_#�����W����+A����+G�?����������W[��B#��@�a���@��*�dyz��� ���[�5����>p�Cuh�c�Uzh��^��K�l�ra��s$N�F�l�>A������y㺜K���>��/�������	����X�\�������w{W�����h��j���R��&m.Yy4��	jb�P�N��Ӻ#�~9V�-~\�y]����$f���w��*;�ȴ�	��i�c����1�.TgR���w�X\L�v��!�Ϸ%�xH=7��-RM�j��^T�ox�Є��?�C�����o�h����>4��a��64�����?�6��7��	���>�J�7�	�:��UtZ[u��A���((�����F��������Y�*7��Z/��e��B	��Q2��E���U����;ʾmϏ�ww��|w����^�FCߵ�%T�(����B�t�oE3����ߡ�[p�����w|o�h��������/����/��������4B�]����A�}<^�ç����O�B��zkΌlyb��(s���~��{�v7i'	��t���z���d���}X�,�ݒN+nO�fo��b���H y�i������	��)��3r���X]�K�,sn��_�AL�Ȓ-WϴnZ ��ny�oO�N���vG(4��Y8����w��אW������q<
��i"H����
�&VX�gC�f:i������k�!*=���{N��f3�H�@���i�l΃���#��V��'�2���n�`A�Z筀��4��fT+<�U;��(fo�����I�OAx�����xk��&q�Ư��2��*���������9�1����	�#���w%����D7�j,�x�?��$���_	���8���I��*P�?�zB�G�P��c��}���Z@��U����%�|p����駍����a�0.��u�
O����7_�?D��fiZt�+n��W��J��{��к�S�y�/%?�k��(��KϷȿ/]����.Ƿ��ryK-A��-�Z�%���J�"|��j�P�����0쉯��VF�͑��(u=���A�,f|4�ٓc�J��e��a��̹ަ�|���ڶ�ɢK�K�xJ�\R�-f?|nѲO����;i箯���|�����K�y�a��-���ħ�D �F"�c�֞h	�~[n���ma��S�gP�e��}逬\R�Y�U�c��K��'�$&+`1٧�|Ĩ`2���͸�?mr�S!���X���n�Ba�����x�&���(QGnK��b9�?�̡�ʿo��������+B5���(ԣ1������.>�^�M�>�$��t�Ip�K0�S>z憨����Qh�����������r�_���9�Q%��C�	�7ڻ�c�?{�R� _8B�e��^�|�V��ȕ�Z�������o��w�(���_h����^�A��T��������j������A�U�����V�s�����=�,F�����xF�W�s�j�~��2P'�S��V`C�W�[�9��L��V�C�P��i��R����^�~���~��f�J��c��H�[�nv���#rzRn����x�^+٠#'Q>͋/��]����gl4-g�N?N�]r+�!������u?ד�M"��8����'-���n���|��3]Lye�*yy\��YxY�f]��f3�P+�1�j6�Z�����mVv�#���j�p���]i��ƶ�~��uc?�nb���Ih��$��@���ܼ��
�햜n��@ܵ�JL(���٧��)�ZyO���\M��Vu N�dZk�N�݊�1����NH��#.���� �OI�B**���XF�D8��`�bTU�eJ¥�����I���)���e`��"��������#<g�_�D/�"��
�T�4��&'��y%�!۞�僆"���+%����y���ke��{*^���	~�����d`�_H������4��E����_��c"�����Ň����%Q��_��`g�?���$xl���?ȷ�?�F�(��ڪZ�Ն����y����?�j�x��P}��ca��O�>�u�D� ��a�+dj�Ѷ>���l[���7��[����?���+�k��N#W�~��);:�^M�f�`�j������aW���3���֥y��$FE�������eu�z5���V�Q��,O"\���㠽�p���-��ZY�����:KwF�z�&xRx�l��?
�����øϔ�[�h��`��Q��j��^(m��\[������XSt��zK����r�,UW�n�[�Ve�m��q_-��no���.#\F���ׄҦ��&��d�X*j3�d��j��|��3�Y�1�˷(;[�}���I��������H��W$��'����/	���Q�?��<$��?��ɐ0�;���p�'��	�����^���c�a@"��׭����p�?>D��0\��,�����$���`�7�����ߡ�{	�X�+��x�_������A"��9���F�h��l�?�	�����������7���a�`������O�g�?��O!N��y!������?ya��H�ü1!*���������H �?��0���E"�v���D�8�
�����/��9�� �D�$�?�������?���`��������?�Q�?�"~@��u�D�?��	��"&$��?�� �8�	`�������������D�8��g�p�̀�������B�8�+$�����������p�?�����^$B�a4��	q꿙��|�U�������_�?����p�����Wh�UL�2JRr$��Y�*�h�D�d)Ue�*����irN{(R�r��1���ԧ��#	�����8�?����m��"�"�N����[�jEn�,vjd�]���v ��"Ha�@����n�һV���.?B�B����S!���'L���u�5j��f���n��u�ؖG��▽���ҦA��R��I���i�-��Μ�k�VS/>�[\qle���tX=�k[����fX�)�w���C�]�	C�?�������&I�����I�8�'>����� 70�Zx�H�C�/><���Iz�(�
�&1H9	�J*�)�;�>5xf��+}�9��?kL��l!+��Ɩ��v�^!�8��z����S/e�����&e�+Pӭ_�M�����&Ĭ���*�I�T����S������1!N��H7��=V������b����_0������b���0F$B�Q����@������;�ר�[p<ݖ�Z�o���ߝ�+��]���b�+p�"��3���;ې��m,&�\�nZ�Q���߮�R�HrҐ�a��r�f�j� �d<L� ����$���Y��6��ͥ���Z�*��*�I	����5�<���t��U;�N�Z���Iw9](p-%�SF�����g�Z�{" �\�prM(�YS��/��{�O�������]�\����J���r�D5r��n����n�e}�G�Bv���e�s1-�S���t�O��Ն���RĤFi#���w���#	��`�������x ��PD����.�����/�D�?s!����"������&�������;��CA����w�r@���;���`�O$����-w]�F@���;������� I��@F����K�?b$��`�G���|�H���/��B�	b�p�X��׭���p��ؐ���?ƂD���y�/�?"����0�C�������L���u�i鉦��H�h�?���:��>�#�@�.�w���/�|K�G��<!�wX�z����)��Խ�<-1�N����B�Y�<]N坦Z����$��$���&ʣR�\`ͱY1����xN1�7c����`7\ʺ):�~��|m��)���+��narlZ7ٞVL����R�^�����G��mXq4۱�r�/k���9,�x��-}�C��<��1JN��Ŭ(H�Z�s�ZyO���\M��Vu N�dZk�N�݊�1{=��p�?6Į��-w]�F@��u�D�?��I���&�����/�����$���`�/�������'��OL�]��-wU�J@��u�D�?�A��		��G���F"�8�?6<�������{��ˁ])>�5�b�_���ڰ�]���g���~Ꞩ��E{�,��S��_�  �?nc �koYȭ�.ٴ*aT�b^R�4c������DiT'S��tT/��������<��F-�7҄Rؔ2t�X�e��j��| |K �U@;`�6+��<e��m�"���Ӊ�i��L�L�#RF�˭����-^�(/��;�r�Wq�bג؜*i#�U�锬�V=��w������_`��H���]<�x������I��~!�c�H��9�Q��i��H���N2�Lh&Ӥ�S�FX6�R��a�i��2C��,CLh���R����$����?���h��v�1�1I++WGc��!�"���u	���o8n7�ڬ���\���6���D���S��J��ug�vW�l>G�3JG�HR}����]�$R�]�Y��MQ�M��8
��4p��Ml��p�ϧ"	�������p��+��#	���!���Ć���� p㮊W�$�?����s��`5ӂ�,���C��)�\��ԫ~�N�Fi�L��<�t��R�^wI8��'+ՕE��|�W+
q�mG�SC,�g��MO�uk��T]����������͹�9�E0����"	��=ɰ�g�(���?
�n�	. #1�����`�����?P����5`<H�����1�1�7����鿪�8��Z7�4�¦��Ĭ�)�{�w�xN��u1 �i!��1 ���@�KIj�x�qRe-���|%���(��\�)���e:�2���;C�k,2�r*��v�T�(�W�Kxv��/�|�s�ݧ2	u'�A�u�y��Y�J0�V��a��Wd[�����ȥ��	p�i�Wq�٢���rVy9�����!KS�U���|8����.l�>��xX�+&������}�;��<H�����L���Zw�
��;˰�t��۹>�ֵ�f��XW��SJw�)9�j�k|�*}�lȕ�XoMz#��gF9�o'���;�mye�'7��i6���H@���?A�$�?
̹�Z(�Ou%_E�����ͧ��f+- �n���˵E�#_(~l��҇7�A9�o����̹���/�q�
Ep���k{�;+������������9���%�dY��T����?v7�U?�/=m�y����K2���?l%~a���3������4��6I��`��_4��Ҳi�e�3�GTؘ>j[�f�����k��D״|T�������w�x��^�kpN^�U����V���m����+KZ :Y�;,��J2�*��\W�MLm�[$/�?\�y�*4��؟x����>v�6/�������
��?P'��-P*r�қ���F������@�^�Y�O���.���z�bVz=	4�@j�������Չ���堾��8̴	ok�Z��� �,˴tt�̽�����T�S��t�v�cW�	�^�ÿ�^�Z-d��Q�F��q��?o���g���;p��}�����TuT��nlW������Oǣʡ�k����g0
\�����N���6�*/}2��<�ٲmZ��%P���擧���h����X�4�F� ����&�X����a�W
�zR�L�۽�>���E���������|l�����?Lt"��E�'�_�ܐ*�B<���	�?�cN���ϐ�������s���o��h�X�{�/; w`/|�ތ��|p{A�
�bƟ (�J���>\ua����4ͼ�"?������Kߜ.z�h@�@��x%�\H����}����h�R��^��+����.�D@-;@��*YO�"On���mi������Ǳ`�c�'`�o$����v�V�\"l���p�/�6���[E����j?'<���;~�H{�o���~�];��6�����RTk�5'��W]�^)�D�xj�"D,x2�ܹ&h#{��j�F���2��߽��d�}�o&�_$�������{ ѷ��?��}WW�����a��o���@��[��Wg�7�������_��N�]��:<��o�o���q��������p��c�QSۢ�AhSN@������[��{U�r��m�䣇=�DP��g*8 ����
>9%�c�A���YW_-�m�ua����k�G1����� ?���.z���� �E�;���JB�)����R������n��^��<�����NXb��t����*(,�:\��k�F�����')��cɠ
��)���Eqx7}�bj����?=0�>�Wa�W���i��j��!��R��KE+���@ْ����$P�
=p�`����~d����
� m���4 ״L���}}}*�?����������o���;�������}E���	/Q���	���~�%˲}t��p
N�����]M�#�]ߙ�L:o7�C�~�!���ef��ۮrU�n2h�v�.���n�E�rU�.��r����j�p@HIXP@{A����D$�B8@D �^(��#����v��kfz�C�H=���������g�֩>j���D3�w�ֿO.J��4,m����v)�q��F����es�2���YMS�ض剶Z�އ*ـ�*�*�$��kh���6�
$�ַH!� ��z��rE�c�}�	��C<��%}ؠ�ډ#�%�Jt����v��	�	i[Á���C~���oe��ǘ�;N	��:YP��`5�{�h�"��2�=vJB^�JC�OV�7Ԏ����3��ms{�e�3�?�<��Ot�ަ��]ݹt��g�8�>;#����=���7�@ �8WP��s��ښ��j����S��m�.pf(���F@q�f@	���p3њ
�+�jA��ªP�3��T8$GTH�#2ð�C����i�w=�����BQ!ce@%U6���1�#19O#Ἢfhh��Tn,s��v� ԣ�\��c|1�����#,�'
�Au-��ZB,�+�t��%��/ڏN`�����nw�����2��t����m|�����W��V;��)�́!�dEs�P����{*����#��i}�ZM}h�L��w<')\��������n�	�~���Sw�Ơ�wv��kyp��}����?�<�s�`Yn��O�����9�1����Blg����#�~�F3��}��O
���?�PW��q�z�^R_N\$�Þ8�e�
����<���?��D��=��vM����;y��\^�]Ux�:.�Ah�
�����M���?W��5AX�qQ�7����.xs��B�?��!�����;�����K�7N��|��l��#�B)���&��#�و��5����4"AF���P�P��a�%~�6��mp�`�'�^�CW�	��
�<"^�|��ٷ��U����7��}{�q�����B��ڸ�(��w���"�%^�x� ��]�e���ru�סE�C|}�KX�)j��B�$�49�_��_����S���;�q��s!���0���{d�̆xa$F%�6�<���(�"��u���Y���vFW���m�*\C����.�d��m�;�����X�/��3�|�6ךz_9���&+	T��N'�]|�o�8��y6i�=��$�o�<��k({���E��R$\/��:y�\�Y��ϻnT��4�<�%M�ۃh��0�8ni���� 8���ܔ]��c�L�֨������n/��8t�:X�m�u�o��V�mQ+�{�`����ʯ��"�ᵴ��0�LR��U6��Ҏ�����
��t@����)϶��!����v;>w"�:T�S���'�yqY��'����4�%8��n� S�O�á<C�Dخ�P�,X� m�"m���I9
՘�$4����{'$�$���>���rK?z��B$IK�[��*����r�{�3�6o,�q���;���:N�FЄ>�PW5�z�W�7�����Ѐ�cc�О}��ݕ;��}�Ɏ��Ǐw���ɏ��-d������	�c;��1�`s�n��Ơ>{E�(�3J�"����j��e�O4c�sm���mO�~�4a�޳'Ř�>�r�P|�+�3i��fWnݼ�M��U��BU2Q�gI��-7 ��&5�����S.�^�~���9���Ţ��@($=s�9�����9��Cv4FN�l3�@�x�';���0�.��w5;���g�
 �3���6�]�C�7[�%j�}��[B����C�%�Q�L��W�c�A	���t���e�� �4�;���w�?�Y��	%�Ӎ8��V�h`P�Mo<��JE1��"�+�~��Ȇ9j;�9*ݲ#�a�r�5�Z�l�wX/7���
jtXhY�c��zQ�Sn�b���m�k��#�i�u��t�a�%Y/a!2P��p�?�E4M�C
�M�O�*��]�,9cP^�Pd[IYQ�wy����X���-�kj��	�`��+7�ϫ���?�'��\����<��I��s?�����?�����_q�G�_(�_����?�ͯ?��w(�)�G���ƭ��6�l�����]�kL����UM�LPq!�bA&�P�TD�X.Р��(��ذJ�4۔�Z�,� 6�w��O?�}��K?���?���i�3��O�{@�v |7@�V��Ƿ���]4��뷉ﾽn���Ϸ���l~�����^�Jy�����#�����F��,C�� :���\�B<�ȵ�����HGRku*�h�@a':�
��l̠�0M�W�BY�!X�XT�+�	K��'J���BU�lȤc)[�cQ��@��v�l�1�RT�3��B#��K%�$��"EMK��p$�z���!)%y���4pH`�7�m8��41u�0������)(�%�$ cH���k~7�$d�h��E��n���{�Y��f�������hZ>��=j>ʶ�J|`X�6��t�ZLmu�=O$��u4�h�b���l[�6�D`��&'{�0Hi8>_K�h��.^f�&�Ly��4�6�#��B+)����%�R�H��#���iv�6nR�Y���6ۃ#���S�͆�Q錢5YhI#p	�|K�T��Vk��,U���{�q+&&��r�Z���|��'�W����=q��PhJ�}��?����JSI��*����٭��&g�AH7��Q8*�̟7�X����bB22��m��%���T��m�,��6���NSm%+��i�#�RY��"]Ei�p�@�m ����aI14�h���
Yv$WY~��G��<H> ���8�w-P��q�,훙I({����v��۠Z,���~�[��J�&��{	Y-�:+���`gK!ђ�|��3�,ٚ�u��hF�$��6@��T+�K.`,B�;</!P1H'N])�ǋ�ް.�CQ1�b�;��z%M�\n�%8I��l���ě^�0Rm��KB%&b��W�@Lh5�5�	��[�����V(.�Z�_�L�#���o���Ǚ�lz��	SȂ8�"�q	�K���g1&���J�?�+�:x���i���r��PPJqdv�<�#L�T1��).���b�?;mv�/��,8�X�"c�lϳ����R��6=`��j�'����Ww�l~�k��y���d(=G��V��Gz�^-W��̘$D3RM�]���-�y����1���ԋSC���m���d������*�'T7��V��0D*Bv2?�і��r2ߙO)%���4�.�����O�OM�H�c!�4�ǰ-v�����4ѯU[}�G�0�vc"�	񓸑MuiMH���u�R��J��f\nv��Xo�z�9R�������_ܸE�Clw���7^�|��:ޟ�!�8�|���r9���[Nt9Fځ�üi�ʌ�O���2��}��C�w�k�NIg}��%�����
q�x�k�Yو?x�'�{���7��!�77��q�t���=�w�yߣ�?�P�e�H^^�|q��ʖ�G���*pjS9e���U�����9e1�(�\��@仞��"�4������8�Ȼ
��|!��J�BtN%R�1��[�A^Kt
 ���dO���l��Ԗ����^[��X��)� 9��
7��^"���Az�ǃ��w��� y�!�{z���t��Ln���B���4��:��k��ٮ�b�;���z y^?�f��A�A�ە^o�
����=�A�`����V�
�NHKj�A�*ě���km�ж�~�*vҌ_%����P�{�?����&���(ji�(Vzi���L�j����)�?x���"EE��gN:ȉ9��:��^���G�IU�9�����Ͳa��wgYÄi���Ҧ�!�;xZyw�`��ל�A�/�mT�q!y9����tp�QG�^M�G��l�3y������~=^��KZ6���V�Be�U�n��bFէ�^=B���QA�����t��,ϕjG٬$XkL��# ]����H��;�X�U�3b+�:����x+Tm��5��� ����X2}
�9^�b����r�k����NU��:ҥ�$���8��GuIH�e(0�x�	'S�f7��E!�7��l:J�6�M� ]�X3��]�'��e��In~���I�u}�����n.����-�n^&��/�'�p�/����s|Ѣf���}*Fl����_E��Z�[��@#�w�+�i��|%*��vI�k�[ī��'O�w�<!=�o��0Mپ�L�N�nӋ�Ώ��x_6tՎ!}�(�KF�^��ӯ��)�j��o�LXP��\{�L����k�qy$;J��s<�C���y�#�]grxUj��YKl�wς�<s-��x��w�<�s��ջn('�w^���E��?� ��h��9�{��ұKާ��X@W4|����>Z�hj�W@BC���D�}ض��tA���TNNc�z�:��&cI(�E�)��"�4�\���R��Ap�8�-{t�m���'��ɚ� �/� ����E�u� ִ�n���j��IE��ʍF#��!UV)Zc���e�㘈
����j��Br���pDcB%s�vhu����.�;��۪�21�qO[���C[(����q����{h��1�����k/`������\1.!&��P�3��\2#��G����&Ke!���E�Tz���ΤF��Ē$�S��#�)��{̗@�^����;�3Ї�݅��:�Zmg��g\��v��r���]�oF��9�Gm�5T�-�����N�٪�K!�'90؋Y��6��fWw�VȞ���8]������_���i/`�3�/��{���ӓ��8�R�����'I�B��\%ݗ�&���G�~����Q�"��q�q<v�eF]��C�<�竴�؝1�4�Tۜ���Ć�?�
�j��'��=r��p9�m��§k�. �G��f1B<	������e>ʗ�G1����C�Ub�x������F��s�T�V�gXQʶ���J\n�(S�s_h�B/�1��Y��q��*�=�F��mĘ^��ܷ^'��������{׶�*�E��
�;bƘ�;rb&�Q)������
*(�� �JOU�:u��ګ#��3�LX�w��+N�UX��X����7
�����4�.zF�:=.����׉�5���B�`^��DU���4+~UG��a�����6�
Z�Eɏ�_�w�~�x#�����?��?�������2��3�Hy&���d
����n2�N��N��>7��Jf�_�a����¢T'�T�>U��^�}R�=�?���<����+�#�Վ*x�K��]������2���)M�悛����G&��e����U���O�m�|��s�Q"ߋCݾ=hķ��/�� x�5W�~�{������uL	�vێ�3޾�<&�D�p��:{T�g&���oǌ� �$,���F�#���L]$��Rţ���Oya�Q�w�7����pf�̆9>�%��@&#�glo�Ìe�3�1�'*o���ͱ���{�0���/�Jan��װ�ʄ:>�����+�{&z~����z �>�-�1���{�*/������0�sk��e�zeҜs��4�4�PWpPGXjЋW)^�婗
�"W䪈�s��O��!5O	���"��9Wr��;��~?�3G^�A�fd���W`����s���l�3	Y���CL���[�i�%*�M�2�&������yt(���w��������{x����u�v��a���fs���:M���'��w�RR( ��'����1Y�n�Ɗ�ߧ� �/�M�g����(��R��d�<Z*˄Ke��&�3C/��soJ;f���:sA=У��_7�B[�U/2o�5Q�q��Z��ћ���c�Q�?��aa�2m$ɱ6�af����5���R:�y�&���L��|L�;50�D6��T=e��m�׳�] ~L�-ؗ�-���m��f�qc!��XCpɱ�������6^O�w�3�6����"��I��8hgx��f��S�n0��-�mX��^���ܖl�v�����"�v�79<�*,-|3�G�x|ތ�v3����r��u��B�M�ţ
�b��z1	_�i}Hn�.*프�^��i~?o��=��߻~'����}�ZpU�ph{�|�k
��XOԹ[�K/��BqQ~�Q�l>��׭���W l�y���޾w�8�����O�^����f"����\�wS�M��?����f/BaxF�zDޓoW5�k{L~�C�r���k2���g ��e����������-ȇ�H�o�ڶe���ɩ�4��L��}cQ�0ŵ8Kd��h�5�fLp$�a�P��`NR��*6�mw���f�7X_�x��R�tr|1\�c�L����tp�!f���#�U�}}����~6��؏ o�v���0��F��o,���ۍ)���@��@��@�����^�z:^�= ������I��w������?h����ώ�=�����O���������n���M��ǁ?r���ؖY�X��8����±~�_��gŰ��+��=78��ڶ�׮{���)bx�ݹ��86
���?E2��q ��c�K��
�?���῿��t?|U������bA��K����x 
��@

���@��+�CH��w�n���bAl��1dU�h1�!���CmDP�1Tu��c�A�����	�!4��:40W���_�x~i���'h�����_b���WoJ]��b�d��ʜ)r���POl�F��F���N,{��m�+$�m�V��2p1��mjD���]w+��&�C6�bNɭ�QSԜ3��-eu���Rm��r/ߙL��Hmb.��;}&���S�6���x^���gub	�en^���w7�t��i��a�?9�����o�q�����a�7���q���?	�b���?&}�_���������?�?$��A0z�}����8��x �'>������ V�b�?���O1��?�R������%�����?I����Ga�?��Y
N�Յ�i��M��V��a�/��gfb��y��M��٧m�����M�����󍃓h�N=�D+��1RY<��+����ֽ�T�����>�����ϐޔׂX֏��"�X֫P�K��������(�q�*?@^���P��K����Xi�k���]�2��I_�M)�.��^��ė�ʬ�e��Ψ�ʜ\T��ɄR�3Xz�|��H�2�7�)�K�'O�m��p������`l�f�S��f��N�)y��"Ȝ�/�u���"�fe�ɋ�r�2tI��֨P��	�D�IU�(�}���O���#H�t������}�̫�걹�5�2�2ZV��u٭0̙�٢d�^T��C�h�KU�<�e6-乫��*:�$�l��N�{�$ͤ����
�{���� ����������_*����� ��	i���i��)�>����c�[�#����9������|'�ΟزA9ӎ�������>����O�gr?����|8�3H�D>���y%3�������}��>�Y��>_��fNV:�O{~1��ƹJ���W��#c�:�:��ܙ.W�=5z�rv�!�C�Xݶ���5J��_H�շ�>Oi�ȏ�}�Tw�b�,㮸is+u�@O�7�Izې��}�o�F���nާ�_Os������h*.�c�sꐝT:�:k.I���A�lLA*=��E��^��6����K�n�v�l-KK�-"����:��?m� ���'�4�a�(,$������
����Đ2�����
����I��@�	��@�	�����`�`�Ł4��Ą��� ��׶�R��}��4�H�?���_�4����ތ�o���v���;����.7�qYn�'u�c�����E����~}��{�^w��w둷����rg�dž��$mn�FMa��+�m�����*U̷�
�DK�%�-9���Ll!o��=zD���Z[�z�d5�jU�ЭGn�z�S8/���cN��p�']�)/4<��n���>�{��[~�͆4�dr��8"l���>�h�2
�a��3�Ϭ�*�Ws%	-�-n���;��6{6G�|70`�Y�C�Pb���b���]T���A��T����/����{ǵ�������m����	���#��ǂT��p�a�>�����ؐ�S��P�e55H-�1���u�&T��qB�QB�u�`	5P8#�������,�L��P��݄��b�J#�����[.86Kl��<�L�$D���|~ز�ds����KXQ����%�?�ֳ�]���-{��As�L�tLqR(t*u��7졶̙�Yr7Vs'��2���i��A�39$=��s��Mi����K����Ii��c��n`ҽ�����/9|����6��F�[�g2f��#�[�tgVY��5�:�2{s���
A�Į`�sF����]V�J*qȍ��ך肰���D��CT�v��me�s�/�6�v���h��뽆ȡ2�kk
���"�?�	!��������7@� �+9@��A�����	���� Ra�������_x��|�Ϥ/��u�tK���3S�0q"��w���i"��nx��/ZM��Ϝ���� ȵ=�� �T�Kݹ>�Z�Hp��g p���&���e+�M���g�l�!�l1��O�T)Z�V��,	Ϛ�f���Ϝ8�2T�I�
ka��zk��lյSs�{�9h<��zft��_x�Bp@�S�=����5o�E�7>n��j�ʕs�Y7��m�/hy�ட��@L)��>׈Vͩ��Q��h�>+-~>x���C��|�����SĆ �]�כe1�n�:����2?��G�b!6=Z���ҙ�*܄�l�hٵ�^ hn�.l�L�ܕ��{掯b��~�~�W#.݉i��0���� ��_W!�#��c����C��4�ā4�?�>�����X���_Z����?�� ��A���A�?Y�'��B<�ƪM����de���RGUVUU�&Y�A�t� Tml���A2�Ҫ���
i�����q�3�5m3;H��_�m�&��r®P��qu�%tU!�eD�fA{^�b}�jȩb[Ri�nV��6�5kA��d᭟k(.��EoߥQ�C���8�������l��XrPl�k(�(B��{������� �$��M�w��d��Da�?��������	1�:\L@�=� ��O��q�n����?�s���vp:����;�����u��]�Ԭn5�����~f&�8�7���C"��N=��xu��L�w��3���V6�j�������(��N5?@ތ�.m��o`�ٮ�V�ve�T�'}�7�\�0Fz��_�*�^��7;��*srQ�&Ja�`���#9ʰޤ��/��<m���%$��-�ރ�-��w�s��@�0�ĳȺY�y�b�\�]Rk�5*ie�?QeRU7�Q�&��Aj�#7hD͕��d^=�T�͍�A�)H�Ѳz��n�aΔ�%������E[\���),�i!�]�\W��^ Yf;�v�\�òcC�?�������继��m�/��c$�B���!<eH���(�����������߰���/��ܹK i��_��K���r����?a %H���H��b����/����o��_�1���@���	JM�F��������i�}p�;	�b���a�0-$�������N
I�?�C$������ų������� ���������/�R�� 3�����@�!���?����:�㧐
�{���� �d�$������
����?��cB���B�G��G��?�� �� ����/)��!���_��K���bH��8D�H���@����X ��� ���������cA�?gbB�B ��k�������?���!�?n������� �����k���
�{`��`�Ł4�3c��� �?~������4�?�?����X�*��0��P����3y͏�1�I-��$NF�������*�gTV�UeU�����_��c��'h���p��כR���2��?�����qr�y�|	��`m��0QT�*^�'9v2�hdP�h{6���|���~h�ߌ�\U��z+8�N��T:�CQ��K.����!��ξѤ�TqnP�n/MLaܳ:��i�pWu.W�l��B���Wƶ"\\���J��S�4���������9��&�4����%�T�?��$�4����?|70���zH����>����B��n�����D�led�i}xh��_����sK��?{Wҥ(�u���7g���߀^PP�~�  b�����O#��x�UT��#ӌF��w�}���{��za�s���>ct���̘&���D�����3��H5c���{��v��l�uq��XJ�M�8�4��f5��TƆ�ﭨ��w�;��%����l������_0�U`��`�����W����B���C�����w����������P�P޲+w���/�����?-�h������N�&�D'2?}���d�QY��M�^���!6,�6ƙ��F���&F#�]�y �V<d�nN�A7n�ٹx>�MD�}JZ1��g���yvn����v���J_3��n�|��w��TX�峰�bU�.�N����a�6�,�;������y�5C鼌�G�Q�r۹M�����@ Z�#���7�b�N$�F>��Sc�a��<������To����HFw4������1����
"���ƈA���J�h�1�����;+�O�����_��_~����%p����2�)��������H�)�C�w���W�O��Jt���������h��ԁ��K�����\
J���\O������������?����+����,������>,�l5J��ERk:�(�n�����ѽ��䯛��Bvܔˏ��.����a�œ凼�܏������B�_�|�ݯ֥gI�ͺ�^�˫syM-A^ǖ{bO���Ր~���$׆:�\QN4��م�Q��\���Uu<�T9�!�&�kĤzF{�-D��#�Z��.���`�S�3�?$�m�_�zb�y�����7o|��]\nk!�c��XT����C���wy�i`�����*��H���[�ކB%g�:^Ht�U���k8:�c�l�ԣ�F��9��"�b"��V���&���=�LCq�G#��K�^�LH�]46b)�c�T��1���~aI�q��)��ԛL��ඕE[�������]��������3����sOФ'DT@x��i6"��� lM	�Gq>0��x@La���P���A�?���#��6���d�7:���qD�L����x�}h}��є�M����^��V+�{��U�@��[���������
�������{��_)(������,��K�����X�_)����:_�?��g��C��'RG�l���i��^�\�/(���:�`���������K��!����Z����%�o�_����l?�m��C%;��HgBkp{VfMT�:�6w����Cs*,	����@�%ޙ$�Y�����<Ӌ�qB�9ϣ�fƉ����퇼����~������2�D,N�~��� 帝��7�O�Xs׳�h�ӳ�D�~b2
Oig��Do�_.�G��ڗ%�s�e�/�y����^dx�(�ͤU8�!:9�ZCcn�X`X۞n�~}��:�?���JB�?��,�8�$y����#������x��\���'�#	������:���?�%�#�?��.3�-���N9
�8\4�#�ͷ�R�Ut��4����e�U� �-���uX�/���O��_>����U�I���������a��Ԃ�ٻ�'���@)��]g���:���j�����P6�?���vp]P����/~��G�������������������t�}���v�g�������_��d��_Z���������Wei�n!*ȏb�)=����ɞ�'[IO�b}y�x~N��\1�����5�ޭ���5�tt�\��<K�k�?\��m~�뜗�I���]����{�N�C������Y���nah:L�~�Z�Ј�m��I�]N�a��ct������"�7�m����P�����W���W�Ţ���;�d�0�b<\-f;ڈ���/�=�g�f,V#����X�M�.�Ͻ���c�D��7��	�� 4ôןf��r���(��fb��c��1Vz4�7�(���rb�N�Nu���8��=�aּy���-�u��O%��U�R�_�A�_S@����_�����?4��������9�-�������߰������SX u���[�Ձ�a��:���Y/Ԣ������ �!��!�� ��)����U�M�����������Ԃ���� ��$���wm��"����������_����2��\�Z ���j�'���8��$T���Q9����+����O$���C.D5(���n��B�G�������Z�?������R�C!�����j��ԃ���(��������?���e � �� ���A���� �r@����_-���+C]�r!�A-���4����������j���p�o)�T��I�������j������*5�h��������2@�?��C���E-����OE�T���)߭�!����������qW�C�oI��,I!��ܔ��&9v�G�A�M#�g�C"�� �|���C��p�g��������S�}�����U����KY���:���zC�Uђ,]:mtע�˿uY~y\�I���8N̲�eȞ
W�SO#[�f=��5IN�2��� ��%Ϻ�u��g���M�'s�GIT�����ޱM���pj��c��)�Ʒ�N'��K�$}��F�l��1/G'���	)�df�޻{SU_��?�V�����v}k�:��P�U�:�?��T�J���7�q)���u�����G��[��׺r��$)�&ZA�v/�m����>��������n�ҥl�]|�-�Ĩ�dl�\x#�6{�nP�iF���I3?��t���Õ7%S}c-9��hW��ﭨ������V�J����#�~ū��A-��`��2����������*�4`u���c�;������o����_���k��n�ey���:HtUr����?m�����KT$M��D��/:P��j�!��67D�Zw���L۝�N�Y�]=0m����y����.ǣ)rFיp�dku��4q�Kn��7�(���
�7���6�"m,�~Vg����[�!kE�>i9��>ߦx+Ū&9��4�P�%��7��]��`�y��(.�o�<������o�|�%�J�ͧ��*��l'�� =ЬC$�����\*c�h��q��T14���y�/�s���4�о�?�l�t�k7��ص���{�:�?����������@�G=Q������������RP���������/^g���P9�������������j��:V��� �������?��������!�U_�o���������`q�JA��R KGY��w�I��-�������}Q�G<�a��T����*������8��2ԇ����*P������� ���v��|���~�;����ԑ�'[�#vw�^�����М����y���V ��M�f?���'������#K��f۷�ߛ���m�ס���p�3�5�=+�&�d�P�;��v��9���^�?n���L��,`Ey�A����8�Ŝ����R3�����u�y���m�y0����y�H"'b?�Qy�r����ш�'e����P4��Yl"��~�d���H��ެ�\��8:�ey㌏9�2�Ҽ�T�o/2<w���f�*�ы�V��17i,0���mO7K��aP�����z����/�7���[�Ղ�a��2Ԋ���P&jQ�?������A��A�W��?�?�z�����w���[�Ղ���"ԉ�| ��Z����_~W�+ʵ��U�������N�%+��vܳF�/������_z|�'�C��.���tS�� ��?f �C�ф�iKwVM��5yC���֦9�fm�2��M.�>G�a�!���	����̢3��c�b��Fv��`���3 �u���  �!����b��x�\�3A�D�0ă��Og�ήLd��9�δ\8��.��lHL.,m�훍]H$�x���<�fEN�>ˢ~4"��g�/_ƿ�����/��S��?��R|K@����_��"��q8��Ԉ�i���⢈�O�pJ�>1���>��I�2D��G�>ǆϑS��o�Y�/�:����?���|���=n¹	����x�qgd���a{�|�u�Ѥ�6�T�;���yBO��51d[O������>NDO��e1�y��05�3�����䨫�鰁M��E[����>wv#8������ա���zT�W�{��?�ա��?��z�9�RV}-�#���P�U������~1��5���6�Kio8��k�v�M:c,��d�ln���'f��m�,���گ�&D�9d�lwr�3©�7�6=٫�jm33ܵu?�W��:�u����"�F�MB��V�c����b8��2P��xp pu�E��U����/����/�@�U����u�C�����ë�����52v�:t"�D��p��ૻ����{��H��� �v�� 4��P����TN�5�"���b��A:�`�$ )F�	��N,뎶�ْj��ЏΌ�jYn������--沔��W�!W�'yb�p^t���^�f1�$����'���פ�@��L^^?����]�7yՐ}숷�5��G"��{E��|��$_^���]>4�dd.�������)q$
?�_q6RSZ5A@�]�C�x�Et�q-&$�T�#���}O��ˎ>��NUU@��s��sK]n��ۭ���C��=�Á{��Z�6����q�t����_�]m�Ok�p�ez��=:i�:7��Z��t�׉��[7��7��Yy�����pO�+������O�0�?��t��0B��o�T������Re9��+*�� �j>"��0�0f��ZX����=ƌzSơQ��́�h��~���~�kr�ꌘQ/	�3���N���$AMy��:�PX��1�󅡘�g��oG	�LF��l��X�#�aa~ݮ�|z6���o�&��M�]{|������x.nnTD�(����*�V~Y���N|M[�6�@#��p �Q�bD�03�#7)h	�`M;M�Y]�;-G����/����eρÅo�0ˠ�]���:q�bg>`���(C��فU��׀D�3�tY�Y�xL��vK~2yNki�0BI�״��2��Q*t&�_$�ȯ�1�P��]p���9vB _� �79��I���\�:춏�*g)�Fvw5x��d�V���,�֭��Q�n-��r$�|I���ZΥy�,�״�C�z�nN�^�jt�N��O��Hv�4/@'�N�ߘq�2��zf��5��1և�W�*Mf�<8)c��n�p5eS���U��*8.�����^��58��L�x�l�t��≋Wt��U���y`���������C��b�_�.LE�n�LR�'�D^<��
0<A��R���I�N�4�����}kwDH�N!�_\D��QO�k��4��h!�D��ۏ$IJ`����k����>�:��ꯡ��NQ:��&�"		��BAhq��$�!!X��D�[���šC�-�ϩk����	Ț.�lV��	�ā�V,P6*=�Z)��G�0(����vq��=��^@ܙuu�����f䥾B�ݧA�%<��C�N!R���Y���npt�5;Ǎv3뫞��2�&�N����t'�@�a�]c�����ݱ(�d�ǄO(������b[tU��/�i���*(((((((((((((((((((((((((((����?3i 0 