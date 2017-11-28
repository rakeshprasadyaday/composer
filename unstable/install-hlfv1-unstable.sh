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
� ��Z �=�r��r�=��)'�T��d�fa��^�$ ��(��o-�o�%��C"и����'���@~#���|G~ ���WQ�dJ��fWI$gz�{.=�=�����V@1[m�Ɓ�.���j����p ѨH>�1�����G|X�b�(�1��G�X������ڎl!�ȱ�f_�7+���l�46њ��06�:���M�A��&|'�G�l�7����L�%�!��kcK�j[�~�Ȑ��m�rl�$B���mp���c`�kZM����ꎇ��l��/6.�{���m�%BM�Z�Pq'@:FC��y��B_�� �Gà�"�ȽK2�r�����-����������yA��/���a,p|L����x�C����l7�t-#v�)RT��j�k��EB*��/�W�����%�����Q��·�{ݔUl�`Y��_L����;?��sK�o!������ba��[��Ҍ$X�Mw�\����X���S��-+Mp烧�i���#^���go|�������E��Kt��D������|���pA.�RUl+��v������J4�F��H�:hg�)�<�u� �j�����v����ڮE�t|�mK��R���4��9�Ճ���:��HP�Z�\K')�iۛ��4�jP1[��{T�i�v���◔��:Ӣ�@�/�ɧk
6l�[�i��伬&�uMK�!�'�㾔U�T�JC֌~�m�.iP��R��V��j��-��u�M+��m����c�k�$�+��ml��P4<B�`J
�A�/I��5/��~��Yп~N|"�_J@��\.W��n���t=EO�ug��N�\,������+�\C!�r�����#�P��[fC"F�k�Q
�̠����Ϙ�9�V��t����1Z�!���[�eѻ��sV&bw��-۫|X�~^�ؐ��:9*�8P9)e��sa��<�]��{�T���6l��Q�F�^�V��m5zJb#�F]$-��6;
�c�4�n����$�F$�#����T�����#s �S�t�)�̴U����������(�v'F�i�=� #��S��1Gs��$��c��~�}ra Wp5�"��&|�9h(�9(����6F6ֱ�nCSȤ�z�X��jo=����hcc�ou��~������	����|o~��ᝨ���?�Bh��3�N/��S�|�b�8�y��5͋��h���4�OǶ�0�i��������{��%p���h$^��������S�ؗ��c������[��,<;)5܇�3oӁ��L��5f�:�cwے����Z! �?��cR���G�&Ly'[z_J��_aj�~1���7슾c��z1�|�FD��r��܌�(f����Rv?���rh5�6��l�6v��F��a��k��3���l�~6�m|=M�H<����,�8*W�-��b�}9�K�W��K=�6Mv>���:K��]��X�->�Ձ���Z��.�|u�$��?�7o��T�[F�F�ޡ�GBm�kE�Dy��ed��*�X��G��JOʒ6�Q��C��K6��p�6Z����"�+Zî=��{r�I��Yf�B���Ol�����z�T����&�:����䩨f�-��|$�!�{�.�M?�F_��>0L��d˹Op���yn�������/�_��'k�=1�-��!���j��/�@x ���/�ιa��OL��{�w��`�� ����řk̚���O��hX$�����_ܶ��0k����'��p8�\��i↛8�� lY���ږf8��h�%�d����c��u�x�͵0#�;[��t��~�y�(���D@��pz�Gi_=�$;X$���n!d�SF�1��F�^%������H�M��ˑށ3s+d""�w�LS7Y'ARf�X-�j�ϡ� (	ja`zB���|e��'�-�B�j�n�~aD��S�h�XF��'Μ�l��;�1]����0�H�X�\����?ϥ�Y�L����#�r�_�?��|%��g��q�7��4|t�Y9>�� �"�G�@����ڤ@�rAq�"�	[�F�.L|�;Jd�JC�����o���\
�������(D���B`�����0'}�n�0S�����p/Ϭ�O8�x7$�s#?�$�"9>k���2��A��ȉ� ;��7$w�(�	����tU���<�.׼'�ù���������C���iY�uT�W'�[����>[U1�����54$78Cމ�(���EB�>]#ͱ��jŞт5����c��s������M7��T.�W���֘ـ�d�����.l9ZM#{��a���3J�g�KrZmb����*a������u}<�,џ��� ^�?"�V[���E�0mg3�E8]R�w>E&��cw&ˈ��P*E�V��3���1���K�Y*Ƅ���v��T)���ׯ۠�N�P ���+�ĽCY/�"R�W/v�s����A�A�/�.��G�'�-��M��}h�\�`�?Z��9a�c.�g�9(f�r��n�x�g�G��ġ�i�i;�)ڹL�"C��rm�ѕ�+� X�l���x^��*�c�j�Sban���5E�n(qQc����ʜ9E�7br���d9.�b$��n2�t���m�n]�)@2�mܢA�I[���,��PA#1��f;ZV�:8�SJuG�&0hO�\p�4P@!��4��&P�f�b[(�1�w�N��τ\A"˄dZ��/�*��KO�z� �i�zFd��`Y��>k����>a�l?����<A�����8�%����[|�����eK�7��z���c��.S6���|�S�����
�y�+:��bLX��Z̫���e7<��T���p�l����#�[������/Cj0bH3�&�K�k�2J{�@�ᵅ� ��%�:���!�j�p��@`��]�]�}j�k�%����Kl�c�!c}��+�C�������t� ��)>���^��3�G�K�����1~���s�'1oz
:g�x����/\$6y���������e�3������?�������?L�??���UNE!�QSx��r�Z��x<Z��Q��X���xXTd1���jl#"T7"������˷�$�i�_����m���!�¬|��Y�V}��0IӰM�����W��Y�`����뛕�|3N�߿��!�e~O�t�^���~������}��9��y��ZyH;H�)bm:��'�q~�?o'���y���½����an9�/>��;���1c�����E���"�����A������THx�e��qQ�a��k�?h���/r��:�=Z�0>��Tv�%g�Q�R���ʼG7�BP�`G!�x�@"���#r>��d�R9MS��l6�}�LJJ�.u�	��-Jyw�8�?視�v�|��tS/t����y�=?�Ҁ�U��{@AjnK|%�h䒇�����TL��@��l��m�U�r��Y�T�xyJ9uyZb����2�g�e鵇a������y�=y�hT_'�R�*pg;)I�pr崐o�5�ZS1�;%�++��iVȕ��~9+��S�����G��j�`w����a����:����9h8R�d"�[2�|t�QZ��q9}�K�����o���q����Q�T~�?���k�G1�n��pTt䣈ma�Joge�L�k�;�r�Z2��N�>l�rb\����I�{7�#qY)��n�%
�v�T��{�X��v�{tq�)h��b�Ub��k��b�v,�J�Y-iZ$;������|)��s�A1z"�{����i����I"�H����D�[ }�SOI9��;�\B�m��SI�%mR+5�-4s�])�hY'�Kd�U�kvw[�-Ѐ���oq�L4�	�";0�ݜdj=�����KW��BR�wѷF2]�P-cqC>�G�⡆q�<��Fp�8�t㝤�g��n�l�_�T3c��r:���cn���0�s sZ/)�c5_)J[o:����5`///��`�=Ө�iF�昑�������G�l����{$����4���f������sw�<��S�}	���x��'����������n���1M}���;�&K7�щm�+�P�s\�����5�P\kV����}�+�q~�H�;z&����n���\II*Z��]���\�y������b+��ϫ�����^��E2:�Tw�m��l�t��dE
�*no/�S�p'r3�|�V���ԭ�����_���3x��^&��!!!K�_ ��'1�I̼^3�����#1�H̼3�����1�G̼�3�s�L�k]�/<��.�y��U�/������s����Kx�y��4�o�������WI�e���_��Mw�w|�.)6^J*(�B]J˱��Τ*r9�*wvTwC6�_���A+��1�3'�\3��x��=��Ӕ��6����<w�eH]~�ֺg\|�m��Y9%շ�F�I�>u��v�#��VL�'��-�3�?z��w$�|��b�	J��E�ⳉ���A$�:*�41j�yB��R�{�ko�Y^M��&��� 1p ��}/uߪ�,
��i�F#f���^�B-ِ�䪤��S���O�F�!/��_℞��hP��>{���ْ5c�������M(��6Vh/�0�W�H+�*��.A%S��6����2|��i;޻���s��_�[�b�� C�/�C��:����Ώ�������F�b�K��Ӡ�:�IrU���H��怊�!�N�3���Z>=o�v-:��� ћ��K`ԕ�0e��2����i�G��C�M $H�,�G�D�˱4l�4�ô�m�{���tMK�����dB�zZ�\܋g�ܠ�O~�J�udˆ���tzp�N��4���t�N����B(���W��m��	6�������8���<�/�#.������6Nxs��n��"د��e~y#�򒽑��n�*����m;��B�#t�0����!)�P�y�#�m2�:X�lh�̶��_3MH�Z^��=�B�5w>����8�
1���~��V�<e
��g�YbI����&g��;v1=̷�ۙi�?Ŷ��δ�.���r�J�s:�i�˙vږ5��#-҂悸������r .+b.���g���8�r}���f��MuUdċ��Eċ��ȍ�$�2;�$K�s�W7�\
�9�T;�]�E�d $�tN��hR�j�>�A/W̥!����TbZ��4���P�]��W��'o���#"@��5�o��K�K�U<�!���P���v���Q䫱�-�������a��?�=��59ә�9�@��A��>� ��(;��������R��3���b�l@E�W�@��e���|��E���K�>�t��˲��.pt T��*�]���+�iȽ�a�����޲���Ju�iߏSaƚd w�#g�~��2}�1(��͑S�F��n
�?��B��~���@K��(�"�5����n-�%����е1���c���6.���$���O�����[I���d��O�<�G��/��|w������/4c�?���|���z����'�[b�q���_|�ʽ���"�B�k�Ť�~��T:�M���K���Ig4"�'SYM9-M�q�H娔�#)�ʪIR})�#�$��"�؃������l��ӟ�i��_��'�pk�R?~������������z{u���͛�￹�E�߈���!�����c_Z�ؿߏ}v?�������c�
�����\���,��l{�1˹�F�'m�a�F�OÓZ��`�f�����W�X��'0�Wy 4v�s��X���B�$7�v����/�+�N��A	'=	�-��F��	%a�_�e�r�+��(4���s��v��(��G�@hv����8��Rzs\ȣ�D!�s�9t.*p�-0~eQ����Y��9B�u�:*�bܢz�mQ�^�6H"�e��ph������A������iwb+�:���ĴM͡�r��,�el�*��q�εb����T��ea7�x�n��^/�:����`~�[Ę��vY��m��w�+z���)��zQr�ӌ��%��f"}*���^�rV*=o�Gֲ����ij���m�M�����I�l�8LW�t����I���J;=��'���*lwuP��y�xd*m*-�;��Ӥ��,=��i��p��~�����C�������\JMwF%wF%_=����˭M�^�?�t�/%���^(v���H4s�ɊHW�=�l��˳b��B��BG-.V�=�G�`0S(u�-z0({�'z�n	4�A��-z�\�����s4����o3�Yr����QM:F�����Ҝx+�)�CUVI��ʴq��F�O�
m)�k����M	Қ��ԧ���ȟg?��E���t.�KX��U竣i��RM�OV.�dT>�&�S�\�S�K�T�F`3��Kk�(E�[��6��ݎ�3�T�)g	j���J���f�4$5�X;84��^�6Uꘊ�Y�?���y6=�.����n"|��n��{+v/�
���{/<x�������~�{�����_{������|�)�2e{?�ڽ���}�V�/���k>��><��pܱ�=З�c/�^;p^���{��b?x+�o��"�\��~������ߏ��~����a�_\��*+��Ti-�y';����ԙβ�e�Gi��������e~��[��ϓ�t������KA�G����, �p.�:Zs�sa�j���.����G�8p2ߨ��A�#�"�+������ƅ�����JfEJ�Y:�.ﱓ�V8i`�t=ՙ��Q��p^���^�%M�G��ؓ��,z)���;��Q����|hY;��e�H�#�,u�d��t����i��G�F�!3-%�<����g$�[��N�����{��#�S��K�[hY��w�+� ��z�D�G�q�-����L���htH�v�I�j@��qJN4�Ѱ�*PBtA���n�}"1`�� ej{�����Oʩ��f+1]���"}��o]J4y�(ˡ���<�5�Y��e+5[���3����[`�@�W��>dvT���I�"���z�-��pY5-��{yl���p��ܱ��{@���O��=���rǜ5�W�Xt�*'W'�c�Bݙ�Y���n�g����[Z���v�F{�uV�!�fEszns��`su����8k�O��^�N���ժ��;D�F��)ʜ�(��v<b9a���h�3Z��7�)^/�s����2�����	���L��?��ŲpFT� �f�Ђ4;P��u��;�ʥ�Pl����������H:�	\i�l��`tVLe��b�/<����x�:\+7 �e��I1ߠ�ly�x�L:�_]JU
��Z����1��@䘊:����ĕ��$�[�}A�(���]�F(�H�`�=�	�	�փ/&؎¤	��@�`�=���U'�C� ?ٳ�f��au��쌸ܔ+��	���~���{����jO��I�Z�j�b�
QM���u8(&�Uv67��j0��$���iW��ir�i��W��M{�6��<QjP{'�P�)6�RBI�⼡@a�A�heBO������zء{"}t�[���K�$�Vk�0�������3i$��^8���l�\����ɵj�Y�."�P/M���b�:���^���kQ�-�D�z���$�*�+�:�`�}]������n�b���~�yx����-.'Z���+�˶eZa����1��Z�J��{���ӧO���>��e����ʈ�����c/c/�k�>a�`�ơd��C��x��7�K�����zI��X�M��#��c>����E4Vr$�B]qΦh���H�������Ъ:�l[�cT���o��JG�݋|!�r{���.}�t��?hO�,�f���%�x:y��O�L����F��_(��y�	��������Y��א��K��˩��0d-��(xj| 
�{x�e��a*%��4�F��܅[~ �u��Y&l�y�����a�a�4���k��V?���3`��w���_XϪ��(��b�n��G�Ӟ�k�u����ֳ /i1l�7�Az"fG'�w��� �15��מ�ћB�g��ُ�Ũ%�gP�B����̸�Z>z�ЦAx?�P%P��B��5���7��[��"=|�&��@c��P�#dㅊ��N�qމ�kf��d4�����ՙ7_��	x 2�t��VC�Uha���P�Q��$�N�ǟhwa���9X4Ԣ?��1D�A�X�Փ��ud�;�Lk�����ܘZc�{Xg�~v.�g!낑T8�?i��<� �� ���1l[k�N$g���`��l�N����c�=�D�ي��P`�ub������z��$�fP7�O��bL$s?޴ D����U'���	�˵]3`�L�b]y�!���;*4V�>;���D?m���ئ"����5$�dj�6����_�	
[0���h��ۦ"�i���طh]�
T�}��82x2#�%�А8���ͳ �G���6o	��-)�O���8\^�k��3�Ke�og�"���(l��S~��c[�YSls����dM5Y�����6��2�P����ώ��ό3� �D� �J��de�P�%��c���!�Cx.���>J��䙝�Mx-�"^��{M	���m���S�����WA+O�t@6�+NaC*�eX������I{:<H�z�ؙZ��e|=]F�4D���#EZ��n�fv$-��l�� v�MG`(�~6�{�ܤ�-0Bƣ��2�����Yf�I��*�?ۮK�'���[GY ���ԐL0,u��u��Y��h�o8��L�wu�}��-[ݛ��{��t��)�� ����Dо�"�D�
�&o�F��j����� ���@:ُ��L�!��(�:*����p"��2�#��5��G9��>�7��M�$hk�Md�1�#�sx�\s���<_5
�h���^� '��o(�Dh
�b��݆O|�a�9�5�|cSS~��qKD���)"8oGDw���v�oj��c������3���qvi����2�v�g*�Nޝ��F�C���'��0���i%;b.y�S߿B@tX8��Y��.�L����c�IBs��Np>N��⚇\�V����޹��<+�+4�޵����#��*��TZ&%I�29R�������t_Q�>�f��$�r��#U�/�si)��j��`D[4aP�E�?���0[(Ϗ������v<�7�� '�^�ի�bǂ���j�gI�$9MI�,�,�Q%� ���K9I���TN���tVKJ�
CII0�ٜ��h���401�G��m����G��z��������W��W��~x�c��.,w�v��Q���k\�lkM�k�.rU�IW�+�b�;�*OTM����["W�Y�ɵZOp�]�疆���������_Rt7y'��<X�`Py�"��<�$r<vYi��L`�g�ѹ
�=ؑ��t&aM��n�s��=U��f2¥�k�I�������޾qb{�}M���(���vA���<�p�����> ٍ��������=_krɋ|�x\�������W�5v]ң	�c��͢��1We�5�*>����~"���si���ƾn�؎�'�	?y��Q�l@m��&:Z��[����ZK�ת�x\��N�y ��=	��8�hw����$���:-����pH,�E��"��ahq���E��[ܓ�5S,sA�|��/��?&��`�X]���\6�\	4���Q��ȟ=�f�I_2m�&6	ƛDA'�#���7q����$:�M�F�ݔ����l�1��V�']�&�X����;���o>J@f`�ni헻�� �9�֊C�[#�v�2��f4�8VJ�4xTt{�l[�����jq��&����(����u�s��Y���3�'��߻�����������'�t�n�o#})�S�Y�������H7O��i+�u�Fߥ[H������i���J�2�����?�I����H��������i�ʦ��������!����~+��͝�;4���M�ϔ���#�ם�w+��?M�I`���,��dU����r?I)�*)�L�P�t���J��$�L*�ɸ�)RR���ίv�2���i������u+)��m�I~������wm͉�]��_��[5�Oo��IEE�7_"�(*(ʯ5�Lϴ�$�� ���*�ʤG1�Y{��׳hM�mo��A��=�ۋ=���W#�8 ��,��'�{��9l�:�g#��6�B��N��!C��'.b�.Cm�9�
�-���^9;kI;X����G�eҕ�$Ƈ��o��M�����:�?M8������ϳ!u�N�cT������8��U�	�O`���
T���0X���� �������?�v�/��ǣf��Mj��|j �����8{��������U�� �D����v���{�g���@���)G�0%Z����������W���ꄫ:��B#��`��?*A�_�A�_�������O�� �W��?�ր&��4~���C�o%x��7o���s�S���%�9�<��ݐ�VN!���������ڷ�O�Gv?o�C��������'��Ϣ�<��*#��}{�/k���$pf&��z���R�]�ͼ�_�}4S\:/��l�ix�KՑwI������ɨ�Z�Ȳl�����S�9���������'�={�/O�l�D]"W���������2����N�K�]/��=��{���Bg��3O��9�\B����0�V���lȳR�#I�L����4��|$t��p���=8�냦�B[A̅΍3��L�F�?��׆迧Q� ����[�5����_����U5Q�?�����J �O���O��To��@����@�_G0�_�����������;����U�Q�������@4����������}������}&�S1˅Ch���C�I�߸���~v�����R��d|ѥ.�����a�ٱ-e�g�O��b$%z��ss?ڨBxt���>�cTw�VkT_ը�������;a�`&�X��1]ɞ�z��u}(�B�T�+�;�.��\үD�,�T�[y�㿵�o]��T��F�D�$��9���b�i��-���=�)hG�:�%���>�Lq��(%�c���$����ds��..ͧc}�1f�`���F�?����A�U��ux���B�_������	�O~�Yx����%h��>����i��)��h��C,�|�g���!=��02`��I1�#�������5����Y�w��9�!�F�Ҍ;J���|�<�U[��#�#}��79nnmO�hy��qL���9iwĥ]�-��a==�S�M��-)�ف��,RbYv�Clx	ӹ�C#:�����z�.���M8�!��>�|��	t}kE����C#��jC������Z��f|B4�����?��;�b5�u�N"6���;Z0g�u��ە��
���R�)}�(c)�1�����;����]"�I:����Q���)���պ$��][�5�L�É��F����P���8�	�kB����#8������&���W}��/����/����_��h�:��ǲw���A�U����[^�_�|��FTޑ/<n�l�,�J��gw���U-���0��ooGrU[�� y�����U�>��*U��8	V�C���.x� �<-Rj�h���)���Xck��@��6*j�B���+˒G��Vd��}V�
ʼ��F���t.x����Ê7��f�A�D��@�M�//����z�� ��]��1R��U|"��O�Q4��i,�>�������T�3��d�h�.E����Ŗ�ފ�;U�Ǐ��q���7������5L;wm��{e �f3�+��l!��-�2��~L��ՠ/��*���J�E"!�7�ޥ&�^�pEt�\�vO�/�f/4A����G����Lx4U<�������b0�Q����'�����JP	�C�_cQ�g�?�P�W���������z�p���	��?��|��|��(c��'B*�<��<�����8�Iϟ�n��H��s|H�!�1^���&�����?���9����Tw=�,]�@��'�cA:�FA-���*C�R����Z#ٟ�"ex���Z��V���q��N�b�l7�8�ś�0`��4��e�`�C%��,�ѱ�;��'��ܶ}`��oE��zp��?������P����x�������
4���;���*B5���71d�7����u�?A����W*������T��ߛ�N���U�W��o��@�:�m۱Ѻ�Q�sI�l�*�ļ���Z�e�{��Vc������{ȏ�~�Z�ȿ�~�Ĝ�roB�;բ��:��9r�Y4���l��8�XcϴɊ�y�LFvO�n��ɘMF�b�i����V�:�9�b�L�G�K)�NTh+���@u�[/W~�z�=�n$�a�[�\�Ȋ��#�Q]h��nc���Lj3zL��.�y����H�GRM��4�A$%���,�8���	�.�n��U:����'i�Fjd��n��e��Se�)j����B�c�;���"Q<{��Hh�Xveh����=���&T���~����ϭ����NB�kM���a�ihB��`��! ����7���7�C�����<��h$������	����P9�?}	.@SЈ��A�/�B�_ ��!�����?���@�U��?������:�Q��O�OB�_	�������$������ñP7���������.���Q3����k������J� ��p���_;������J�,��p��Q�o��� � ��~��B#�~����GEh���͐�������n���"4��a-�4����@B�C%��������?迚��C���?��k�C��64��!�j4����@B�C%����������� ��4@�eq��u��ϭ���ϟ���?��^	��0�_9�P���}�������_���!4B�����
4@���K����� ����M�����P���8~�>�����#1n���"�|.�)���psH
<�c=��Y��=�����>����	�O28��5�/��p�����i����t���o���
���f�aj��Z�|���c�§�љ$�)i�aP�4sK�#��at8I�����˶'��rLm�$m�a�P�s1G�n'!팻D'���d���!�*;�K_��X�	E}�������E���7M8�!��>�|��	t}kE����C#��jC������Z��f|B4�����?���N�[��.ڭ��C�VJ��p^�:������E�)[�K�g���:Z�Q�Ԡe��R���Q6�%�ǝ�F�?��=�̎�u��lw���^���ءa���z����p���oE3��������8����;����0��_���`���`�����?��@#������������<��u��b/��D:0[kjf�'Ff���v���߳��I;YtE�����c��%�����zghK>��=CY��Ώ�.N!s��Ob��̓����N?�0�(�&Z0����2��23�K܏�UR�����I�^�M�/��-����I���i��.^?1R����NX	:������.E���Ƣ�sx�z�Xn"��c: �AfP���/�����eϾ��e}y!p:�ɘ���������?��x�[���ՄXTG�9�o�����<Z'yk�D��S���]lw4�7����
� ���yx��������/�������������?���+A�?�z��	�ߕ�����`ī����?�SN �W�&�?����_
��
T��Ϲ����<T������~��QWN ��
����$	�����8m��v�G���|��]��埝�і�%�C"�m��E��q����W� ��C�O���{?^,?��gJ���[��Z��.F/���f]ޜ�[j	��ؒ�-�b|qZU�몋bq��z[�tƁ&�Z�XC�Z2�(�A�`�"e�bBp'״ԈPʖ�ýD୙��b��&q�t��I�O1�C�s���-Z���{r߼�K;7�>�B�f��kA�/������[fե���\��X�D����=����,�e�z'�kҭUH����=J��߸̑�dQb�X�c���Ѧ>��|<\[�N��P8m*!�O�V�Fb젞XX�v�6~���97K�UP�J.�����@�}}�4B��w������?֧1��I�gN� ܻ~�b~�Q�ßY,�"��G�>��<�X��a���Є��~��Z���_%����2-����a�'>�(��0�ý�:����iu1'��~����+U+�{��M����[���7���c���M�8K��?��*A���5U<�W�?�~���W	^��������jΝv�Cqr1v4e������j���h�S
����l�������~ȏx7�y��7�E�����~/��6��$���b���쑑�^K����DxfHMNڜ���`����ۊ7�Ѝ�e����l�)�K	����M���7��~�{}��y��y�RnbQ@�Xp��4n�l�uҽ�F�<k[�r"��u)h�c�O���e=�v|�^:����p�R���Z�D��f�Y;E�h�ߪ��d�e���ѥ��T��Ӷ?QW=
T=���Ee�����{A��h��+A�?�1����������W4�ߧ=����w�Mjjk��O��N�)OZ@.:5{� ���25��D@QO��>ж�N4;��4��_U#����]k��*��#��A�I��3D�\�ο7$�������������=?��O�2kO&̆Dk�C�����\����x%j"�90�Qu����n[ׂ��m�������R����X��i����k����K�4�-���3	�?�?j���_�HY��e `8(3���8��_��,	�*|k�GH�?���LԂ�֝Ʈ^K�V`������O��0h�ʥ�C��u�7���XY7�"
ا"�W�b�Q���ج,���&~N9?W��\4\������CW��+�q��7y:��8���h��ȯ+ᅽ��pR���,������j���D���pZ�n�l�����<st��
�u3�F���LЌ��(m�-9�bY�69�7�6�1�Q���\t^�Q<��(48.���}�Љ�g�և��;mJ���ao��]�ͷ5[P����`�mAVW��z��e�5�]��ڦ<�ju��f���ؽ��EK���v���n��9�]�S%�*[K��("�Y�{�B�W�K'p�/t�MI=����4Y�ĭ��a�O*����Y����Y�X�	i�?L�������E��N��	�?a�'�����o��?�C@&�����_���ё��C!��������[���*@�7���ߠ������y�/�g	|�4����)��tȄ��W�ߡ�gJ���W���E����������_��MT����>w ��������X�)%P�?ԅ@�?�?r��n��B���AF��B "-���������T��P��?�/�����_��H���B���}��L�����H�,�?d��#��U�
��� ������0��/m�u!���}��L�?��###�u!������C���*@��� �������`�'P����a�?b ��o��	��n���_��������D������a�?���_2��p����-�cn|�t@���/�_$��X�!%2��C���%vFkF�"Yf�[eҤK�Y�m�l�$�1,K/k��2�2���?o����ɂ�������Ë���U�qX����K�/W9[�|C�[�נ���eAxz�U^�#-��tl�9�M��)���&�/5�ny5�-k��k���x�!̻\2\�o�V�I�Gu2ȓy~;(���Z1\bM����/0]M�{+Zo�:m[C�pyy�Ǯ��8�$XG��ꗗx�S��x��P_�������U��`�7d����Y���������8D}�,�?�������R�I�69*�y��Z>*�?������vJ��=�]⿚8\�f�V���ŷ�zM��k�(�X8��~U,I��mV�Fa[�3U�%zq��l�PG�6#��o�B���]�ג������@��ڃ����/D&�A�2 �� ��������Ʉ���k�W��߬����Z���մC_�{�u��БE��ڿ���&?��=b����Lx������/;۰��m�p|c�uh�[�ix�ͫ��HӇ����l�'��؊F�-��;�7^9�dq�n�p�Kn+m���������o�bm�W�m�����<�?�*%lS�f�^�7�_���(���Mx�3�&�{�{��s�Ŧ���on�j�s�Wz���{�����I�#rw:5���DG6���*��*�s�^W&\T?�ä��H�c>"��ϋ�8�Fi@ZCJ�w��Z��k��A��_��$�����*޺�zL��(i|���ï�٤���=���F������Ӄ�5��M@�?�?j�������?������9�����������?��\�_,��Z�#��������1����B���@�OZ��}�c��`�G@�G����L�?�F�/��T@��`H�@���/��? #3��?"!�?s���C�G*|3���h��JXڷ��÷�ѱ)��13������n��I�����~��H+���]>�~$���܏$�{E���.���K��{{]�o�脽j�?R��1��+^۔�̴�Ѿ6+��fk�+���w�x{����	k�4O��Ôₒ5:�גj;����_�G�~/i�؍�_MOk��
��,9/�,j�f�)��X�H��|�)�剫a��~9gl������`�x���r�����z������j�^zk��A�b�9�sje�{�>R*U0�ƪW��
;_�O�A&���#��{�8�kq�@���/����Ȓ�?>�^�T�D������ ��������_h�
����=/��R�%�߷�˄��8�?"2��7^ oM&�����o���J2��E�Gu;�Ԫ��;�\�M��~�������Q$ۗ���XwW�zx��)�Q ���O9 �}�����O�ݚF�k%���ݨ��zE�4��Bg�=3(`J�ߔ��Q��y�8�HC:T�L��
=cQV����z �$�� ,I���n�E]N�G�U~^=�C(ܾ.fsSf\�m�a@��RP޻�=^�;���Ayݔ{���Cs{Mi/��<
HSg��n��N3���/��0��č�_��W* ��G}%������eA��č��E��4Ȏ�Se�5�"kY�fh�fΊ�NZ4�3�NФE�x�l҄a��[m�:˘�K��c�V��_�,����?a�:���?���9�[�듩Ǟ�����DS#�n/O�-�ZJ�$,�/���͘,��v��|M�#��
��^�V����h��EMk��3�9�2�8�j�d�4U�h,Z��1q |l�N8��?_K��������p�d�������������`��wI��?t�����V��B�۲�f8V),)m���n�Y�&ٙ<>r����1=�Ho�-�y^���w.�*Q��h��=qH���իd�0;6�ӮX�=�[�nP.Kt��&���hX�K����l��W��d���o����``�db��!� �� ���������,�?�.��Cķ��(������s�cF�m�<���-�^M����������~, �,�2 ������p�i���^^����;�v�n,�9,7��>��e�h,�%6<2Lo����bK͗։��5�T�J����ů�<}n����U;O>�<W�Mx�3�rQ�'�\g �QC�2_ ��0`�ԼRIvÁ��DE��em�a0�Z�Ux<��󛻼�F��?��t�����HO��m�g��}Q8�'���ť��U��Ɇ��;w�J��ʞ�V��D�����%�F�>g��h/ֆ�:�kթݙ&T�(N��_�0~���7Q��w�j�^�fC�q*���?I1E�?�͹m�����k����Ը���yc�p�ֱ����$��*�GA�?��~����Q;�.<$�����Y�9���:[9���	r6��ۅ�jc,s�~_���=���{�뚫ˮߌ������N���/6wy�Tr��O�d�}c^{�'wI(=ny�����#�y���y�d������o�Q���k����N�۸9��0g����g��7�i�UrǬ5w<`��>���=34�xs|9ɣ�ob\W�������c9Y�+ٳ�kz.��9c��f����ǯ��G��t{��9c�K��7<�����\����t�����]�?��������G�^��'�O���b�H���]��`%{����������<׫�m��v��rfɉFZ|	����=�_�3��s�;'nr�7R�2�5�x��|��\4�5�߹��ڹU�d����Ϝ;3�����\����4�֠���4?�$w��M�0Әor��}뵿c��4��n�����I���i�<���o/��ǧ/���]|��n�����4k��\�����+\�[z���qܯR|�_���gg�!��	����-�ݏ�^[h5%E~lϮ"�U��>��)���{ՅY$��A��ԟZ<Ԃ                 �_��Xs�� � 