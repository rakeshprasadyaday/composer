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
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:unstable
docker tag hyperledger/composer-playground:unstable hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.composer-credentials
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer-credentials

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
� �Z �=�v�r�Mr��'����c��쵁�a !��`@X�/ɒ��m�F3x>@��=y�{N^ ��wȏ<G^ ��3�������kj��]]]�Q�U��M�PZ�(F�cX(��`�a�^��ڣ�C4*��pL����"}ćN��.���B4�p�T�\p,� <�M�U��x����E������BfWU���0 xs�����_�U��:l��a.�T۰�Ӛ�25Tk 34��M)��1L�rI [��6�C�٢iH益���n�����Ò\<O����x�e �q�� �@�f�;��x�0��lX�6�(�1(��%�1��m���h�B�Tk�:;� �MC�H�JH1�M
�˕���WB�M3Q(�mX���&�u���3Q�O͹�N��sCG��;��4ꪆ�w��u[S�ê�*�_C�b��vo4�@�]>�ͣ`�"^m]~b���V��⇚F�q(8��x�jxU�Ys�U��p�0�9n�a֐����1�ݣCZ���fG�	�<�At	���ĸ7{�	\ϞsZ��ӊ�>�AҜRm��M�2�f�ϕ���*�Ŗ�x�o�v�_�Aӝl��HD�sJ��]7C6(����5�Yv�x�fB����y�}Hu�d�-��'ϝ�-(>���i7�G��=�l�}����Ѽ�]��ԡ6�K���s��ܻ��w�P7@6<OC�^Q�b��,���P����@��9�_��7e�m��(����k�j.[���������#x�����WO���z�
�&c�� �n>J�~�T�����ǄT�;/V�I�-����X���ӫ�o�s̀X����+^K�0E�������ϭ����Z��n�"�X��6:�XXn���\�_��+����0E�;Pi�
^X�~/uP��8���c������ ��@�NC����@H>�8��`�M�t�"��LP�i�@z�3\��n� ׄ4�C����l�qL����joE��m:�&�競a��������ڞ����vB!��t�ĉ�zFa�fIy�sJ�б��9�sNz%\�4UA�E떰�4Q@�|�ę�3���%_�.�����&z�Y��ҡa��[Y���Qs�����T�j��G�@�|�;��5D����;�:H�!]Q��&�$��ƃ�!M4�T7��CO�����ˉO���A�o�f��;�s�?������&��O��������U�_�c� �偺���<`7�Z���׀��F�DLG�U�1:��a!�6:O�1���|Z�St,���Q��-�&�x�A�a�,x���������}\�q�7�a�AxBx�s��'���U\�0^9��.̬�H9��6՚m@	�@��{Mz1=�@��k����=�I{�E�}v4b���q��3ǰJ8�1�H���4ڕy_ہ1d�n���̴]�̑�������  �'f��k}�!���Ѕ)����.�x�Pm�z�\�+8�M�k�ڷ���\��e�4-,�!����4�A5�
�����}J''���F���d�>gIe�3�#�ׁ��a���N/1nD�r����&+xF��% Ul��^�!N�<Dt�����5��.U�KGT����������L�{�����7�����*`����a������X ��(D'��������'�F~W;s��G3E�#ژih,C�݌	����&!���f�Ie�����0�l鼔,f�ʻ��	y�8�O�+z����G��a��ʁ+�䦥D1�<?����a����Hk�t�1�Z��-d��:��In� ƿ$��`���T� �B�ib�������C�&���T,���9��R����4��xj!<X5�ٍ&����#n�Zh�ݭ?�����7iP.f���[�9���?�M�����"���LVw@k��N��L��AxI�R����O4t�C��nœO�k6�p�-�NN��"�+��f��,9/�w��`��'Do�H��z�_ܿ�G�j*��ò��N'"�5��Ϋ��i�A�� �g�;���g��+����4��4 ���&��XXX��*���y�j�����D�@ �W��z	9&<d����V��0E�'���{�7�����^,j�,5����'�4,������+�ێ�2���XxB�����%0q�+3�бnZ6@�i�/@�Tu�;m��^��1��Kv{d��.�B�9&b�bro��n���/��D�O�a���c��?J���%�`��o٨H��V�)Ë̔�M�wT:���r9�=p���
��H���ij�5$e#�����g:�U�U!j5y��bO �n̅~�UD�����ر2F�O�9���=w�x�X�t��t�l��k�� �]����h�������p�[������P�_ɪ��U���BDl�p�RH�G��U��w]2�p R���xr�y�n >��E�
�����]
x���T��(�Zu�����/s)d��cY���D!���V�����9�s��O�����o�{�j�`�!�CXq��y���q�������^��|'R��@`@�� �@ [1����O|�wu��GC�6�w�����|�\[%�4�/@e�NN��B�P�ZT���[`Dnx�E5ˍ�(|�J�c��͆=��*3$��G�F�͚���	yN7��IR�H�_�6���qy�T� �#�@�p!�V�*����য়�|��@�nw��:�z����}��f��^��GR>�a�`�nը��e�Ϝx�Qxϖx�L>2VFd_���{�bʋOM}�c����9�=�1V����x�&����w����X����Yo���k�\3x�樘=�����|�{òG�cĠ�����	u�
Ұ��d7���JV��4?��Č�p�-��ϋV9�V��s���8�+bu[��B��vrJX��o�`��� �CQ��έ����pm����,� �vP��A��/� ����3����Ѳ5�a#}Ji"�����Έ(d�����z�E�G���~l����]i=|	/��m���^�<[z����L����R��
^���U�j,ssL�_�|[�o���E�_D����Hxm��� ��j�T�l����ez���\1����-c����D�������������/Ƅ��������0V�]����O�����FM@w��c��2�>E�i�0�D�A�Q:S ��+�Y�0�jX�o����ͨ}����u�^�a�}n�k�$Z�����c,6�X�"���za�޺3�6<+�uc�z	��5��������`���:�����|����?Vw��"�.OA�rQd����Eb���Hx��`��[�y�ݷ���������b�~b���g�r�(
����+���j]T���h�D!��#1*ƫ�@1���jl;"T�#��������$�i�_���:�x��"��l|��%��6}��0IC��V���?n��1��F����7�f�ȿ��7#:,����t�������b���{�d��������O�1���8ED�M}8^� �G��v��w���O5�;�q��?̭����'���Sz�:�����#��z�_|�l,�HSC�ᴡ�1�
r����ul?��}��Ź7�b<���Ȓ�Uod��c�1ʲG7�
uH�#�;���r&��|"��&��LS��l6��H&%%ِzل����s���k�D�o������
�d�4�o�e�.8���+� S�Z��ȉf.y|�����b��?Ƥ��V�Y�h�j��O���Tq�r�穉�;]i��SA�:�/3e鍋a��L�v%;go��ꛄuV�\T�r/%A'W��|�~О���k*�\Y��/�B����Yᄤ]�4n��N?�HTs��,������{}\���9�q�u�Dn� �-xr�Uڑ�iY>�%
n�/s�wzEH;Y��z��o��+��KpC��N
'E�D$�z��P&m+�K����Vˉ3ܓ�\&���)�ĸԐ3ɤ��'�I\VJd����D�ϴ.K�ܱqЍ�ߨ��';���pR,�N�����V��Oᾴ�����Fr���Y���ΗbY+W;*F�D��i��/���AN�X`nk����
d��))G�z��KH�mY���\�"��e{�V.�/em�:�D6��ŃVo���������&�LGs��:��g����a��&%�!��J2[H��~!�NOʍ��)��U<r5���T6�J�I�w�&k�F�Q��G�v�u�f���l/�9�w�������~R�Ǻ�|�(���锗�)b�^__C�����8P���1������x�����G9��<?c0X�Mð��-����'��ˮ����n�V4������O��������n�}���>fr��ޓ�y{t"�� ѡ
��e{�}C��V5��9;�����3'����)�\���4�ʕ����MZ�J���UZWi��=�:�I�x^E�ǌxܪ��H?��P�r�'d�F�y�W�)
H��JU��Aj�̡6J�F.���|7��{�ˁe�� Q�Ա@�yQ�|�!BBB���c'1˚I̲V����,k#1˚H̲����,k1˚G̲���q�L�����ѯ<��.�e��M�/���V���s����kx�e��4�o��?+��WId�~�/��ɽ�=O�KJ�����
J�Аd�r:U������I�	Y<z����v�1c��ҹ���x��9N�MÐ����к�u��KG=��R{�\|��7�Y����~n����k����݊	�a[[X���޼�	��a5�$�Nߤq��D�ev�@�4P$i(":/jA�	��?J�	�?{p���*2w���o0F�`j��zh6,@
�U]��F�D���e�6�a�\���V�n���ɒ�����K���*x ���?�=���ц��|�4���&�R)tK�+W�AiF�������W����qCY�6x ����B�7w�"�{�YL"�d
8y����t�6���;������Wtrɂܣ������/� V5�� tI��T��ؽo
��tr������c�y �q ��
z����c���2��m�F��G�6�< u M�I�$�e�*�0m���>�ۢ��1��3 �*��'oO&$��E��Q�y���T���Q���ny��B=裓�}f���xz���=K�#IV3��P���{�C�.I��3�/���t��t9�M���P�t��YN;]δ���Qs@H�0H���{�
���@�� ��!"����隮ޕ�l�ˎ�x�{��x�f���	(���u�mFЄ:�TW�� ����*��8�����蛀7F��g�;�y�w����ɏ�_	ċM#�km�~8�s`�`�]��� 4r�r	$HB^���S՚ D����ᝡv��n�~�4a�>r'�X��0�;nW�3��i�;�3��kU=@�`2_�*؍8�a��M�������1�@��t�~�6�Hc��S��_�S5�"b�k4�抱� b�<�H%�i�>T݋:�+�n�b<9s6�P>�u�~�5]�V���Q�$$?>��u����WcE]�5��=p^7ҟY��
Ě���:����?�?� ��	);���������R��=C�JϘY�� ����X%e�x�<��F�B�M������eYݸ�9:*8�=T���p�{�a�ؽ�a����Hw�=o%��Ѱ�� aM2��հ3�Ǐ�WM���0��&wGN-��+��H�d+	z=��"O�4��)�!>5����nM�5�������1���C���:�^�S�xl{�����?��C��'�/R?�����?7����_���?׈������o~�ɿD~�">���QĒ�����|��k{?�wE^G^װ�I]��ۉT<WT���N�U*�'Ҳ��j*���T"�L��tRMf���}���J~I�r�~��O��}���~���W~�ٟ.����<��I�wb�wc�ߊE��m���-
+��oG������z+����� ������G|El�"�v/�Ž�?�#~ڳo���k���8��cpu��׹�\d2��(e�j�:k9,���v>�Uk�:ǜ�+ttL����?:&Bg�]����b}��1�Y�=_^�R��g��wb�ʊ�ų�B<�'ų.�iK7��bQ\�VL�=\�H�q,���ݮ	�3�:�Ť;�.�1'��wEޡ$؅����2�ѕ��:yg8�,�oQ':mʑ�Y���b�q
����r�i&wg��F51��T��r���:VG�%;R��h9j�ݤ�H睉uD���@hq�2T��WK�v�x0���*��̛Թ3W�V
fL@�/�c��و՘z1�2p��Hd2�H��Gd:�ͣ��98��fn9:[_1|�^O��V�
�6���i��I�98�R���Լ.���rg<�&�m��A6A�-�gQ�uf��k�M,�#�:�˭��@�$r���:���L�	���J����l��0�0󉜒�{8=&�����9���+����ZjzaT�¨���Q	�U��f��#���d���J�Cb� ;��D�Y�lE�*�n�h��ˋb�����5.ĶRX�${���!P�X��Z�H��N�d�"��@��_tcr�v����ɠ���f�X��.���.t�J���ݶ��-�y^0��"=Td��h����DLo�D�݆c(��ɔ�͉c�~���^���y��L� �d1@d[|e�:�Җ�(Vs�r�^ZRN|P?w.?e�8Od�1��ٔJ�I-�T-��9�q��e�e2n�2Tr���r��sF�8�U�P=:�S�n�:��%��@���F�Lj�_Ae���hp����/�y'�y�}e����ۻ����o�޼�o�f%���&��|���"y
5���|yc�+�=���߉z���yMԃtً�_������y%�RЀˊE���Z���;��::�������S���^���"�w/x���ZVV^AV�����̼*Y:[c��
�n���~��ҳ��y�i�2?Go�}�ɻ���$"y̹��h�"�>�"n�5�9Ხ��k�r�m|"�-�W�k(RQ�#�Z��"�:����f�ή�|1=K�R�nRS�gu"��%��#%;�*�QL�;�}�u��A/��F�ڳ&�^t���W'�|IӅI�ؤ2q"1U��d���bt|�d��tX�ã����� +1���b��iu�ͱ@�W#�e��δ�����A:m��y9�b�u�Ms�f��p��R�����O��vR�)i��������Ó*� �XR�֭Ѱ����h�\5&1���������t��r[8+%�=A4���RH�W���q-�䐢,�r�S�
BkTg�2�)W-m6h�.���3��-�|�_�V��+��W��Qe��G"�*6q�I|\�:����p�e�0a��qA�s|Ɨ}r'nK�>�X�?c:^����mcV/�L��%�_�)����5{��V�ѝ�%�*�]�>7�J9z0l���Dm��C.A���jw�ƨ�����.ԘqFϝ��
�jv�+��v�p��U�yWQΉ���r���`2Z{���V�%-_\�5�?;H��GpM'�4�f[�±�+����	6���w�����Z*��RK��fz^"�x_pF�+��E�!A��8)�)�a��|����K���5,Ũ-��I3SZ�=�N����DEB�d�$be>�O�'zz&RY��@\���82�|��O�,��h�݂&�m�`|aB���+�	��1_�4�:�"��^�4K�x�u�;�M��Ѭ�D-yd�G|v�b�	���~��̻������@�P�`��N%�d�2UI��y<(čUf6׉�j0E���%���n�;�y�����WP��5v�Zi-֓g*��qSbbQ�⼁@a�AYofXJK��uy1���q��J��IvQc�#"a�I�2�p���(`������lja�W�.��R�v{�l��U�*b
���Z/�(�M���_��V݂Bt�7޼L|�2߸P��q��E�eOu�T,��g����Ϣ�\ul�,i9Q#oF^#^�L���?��7h�+5�V��=��'O�P�>yBy�I���H����W#���k�>�_c��10t��!�e� �Ле^��q��x���>�C3!������2�~> ~��6�
4��l��n��� �@��M�(SղT+���'��l��G�أ�k�˨�/��^<_����'�73���5��T�����xq��<����E��g���I�s=��z@rz��b���n��Sa�*��(x
9���9<L�<�0�9S0Rm�.��Ѹخ���4P�Ϻ_^��C���0�y<�������o��N@Ϸ�uH~��\�
k#�F�Ͳ$�Oֻ=���1�f����A^ScP�g��tE��F�7�r�chBoo=<��w��M�$�p��KaKPנ�3��?l=�s��,]�AdS��A����PR��"��5����w��[���b=���$��y�m�p��	I
6i̙��c�,�)d����1�+3w���� l��|m��m�LX�4d	���$���O�����	��N���pB�m,|�J݇6ꝫ�9�F��x�O�1��ٰ�G�A8ĺP�F�b����^�0S���S߶�&7����k^`+�dw`.�Cr3���<Mg+VN�AP�E։}D3�2.�Eϓ�	 ݰ6��=}�C�aB�"/�|�XO�F�DN'�/��H|�@\3�7�at�G�n>�8Ӹ70�����}/�jc��u�6�x��2�0ͯ!�$SӲ��~�'8l�l���>�E�g�����ԚcϢu�W�	��Hl��'�K��q�{�kA|�{�`ؼ%pj&��D>��N��9I�V�׀��5��9���
�	��|��c���)�9`��zW����-[�
��HWS
y �=A�%�hs�5���,�UD���}���}�9��2,��}�}lӻ?�!p�N�*�P��`ɽ���eo��x���1������L&�v:@���؀�P@ʨ,��9$ik:�HAz�؞���e|=�M��14L���c,H�-����>��vU �N��v�φZ��Xx�|#�X�6F��<��U�.m8��X���Q.��t\{�0D�^�����R�M\7���yU�����Rdí�a�]l�j�$x���G2~2T��(������ZCa�^��"*$�� �v���#��z@�My#r���0T3;5�H<��xw��8)�/0�c	`���eb� U��#r
�C7nlڛ��_�������GfcYz�)�<��o���/��B��e�����u$�)xp�1�v]q�t��j;�t��MM��3�-1�c�G���|>� �B$?ص"����������z��b��k���2Mo�N�S�����B��B��j%;b.��S?�A@t�9��Y߳�3lCȝ�S�QT�{ѝ�<��Q��7���Va ��%޻�:<��T�^�^��ʊ�����hZ�x2%� ��t�VA2�Ɠ�T���}JI�) h9�giE���l
$�)�"��Cb/t�}E�r�l�4/��J(����q5^�L�Nݰ�7�Ŏ		̅9T�O��9��,��XZ
E��^d �T"��c�TF�YA!�@�d&�&�*R@�C>���o��s�7���m#54\�>�oDo�o
���=�]X3�Z�,�#�5땸�V߀X]�+|�)����2̗)�<�.�&4%��p\�o6Űv�47���"/��#��M������_ra�N嘲ج	ܣ���u�Q��M@!����*��pEv��ݙ�9�����բִ�t{0�1.]��M��T� t�dt׍;�E�h��F��ܶ��Fw�!���n��}��n|�b3�r�G�n��j�GH^*���7������r�.Mp<�*lf=O�
W�
��l�/��(�g��it:{��C+���$��b䕻G�>�]2�xki�m\5w��M)W���i����Ƒ{��'�����J7H�ݐ��	���k�T�H3����'��
�lSB���'�H�4�G9s�p��s�V�ȱ^��_� �PqE>Lf3�gJ��ߖ@������;������KH�ڜ$o����$:�ĩ/O�7�|xo6��vS��<߲^��d7[��0tE��c�:]��j�y(���������jv���8[3��o��;�Ǟ�eX�v�TT(:R�V�)j��-������C������H�����%��"����?�������3��<�6��S���<����I��������{���n6�����c�L�E�6��W|{#Z�aq"������⬠(����ʮ���ʪ��+�kёaؙ�����o���ϒ��������Z����������.	��6|Z���:��y]���?���@h`�/�@S�W��@��1���W	U��(�kG8��W��	<�c�	���'���q>���(�����È�I/�_�Q���
�?�w����*�/���1�?|�s7��&O7ە�<v�Xc<��͎�愖4�}j0ˢ�y|R��ӟ�V�h��x��ٚ�����l*"{�����e�Ox']��9啳s����ݝ-�xx��:��4�ҍ<�5Wʷ�~�wݝ?����������ސ�_'�*��{����*@A�I�A����������u��O�?�����cn����<5���S���S��_���}��% ��O���F �U�?���ϰ��ς�WZ���G��%ZU��?��${��,��� �ꄣ:��u�O���#�B�G% ����ڀ��s�?$����� �����Ck ���!��?	��[	o���-����*]�?�y����B'b��SH��e-�!m_�?G��O�gf?o�aF�x���m�{��gQ��OfU0����ϗ�Oli�;�~��Z�w/�:����^3S]&/F��.Ӊ27皣�V�*��V�kM������e�e�lb_����a�Od���s�/c�؏�}��|��25鐹z�{o���.S̷4{����қm��|���9�)_���Y���S#���b�F�s�C#��rʬ�{�D���U�0�w��N>�^<�|v�?�˃�����Y���3���%��P����Ӏ(� �����������Z�[�������'�������`���7���H�U���������������������������� ��@P�����>���]��k�?:��S1�Ř%u�Z��َ~��+������KX_���Ő��co��������'Ϛ��&�P^��ϭ�p���1-~���.��;�Xsz��{��%!���o��	���t�wx`�7C�45{
뱿���h��S\�>�Ȇ(�sH��d�ж�����K�{����-m.�tJvJ�)���%Kn"emf�1��IIf���m�S�?:Slq�MZ�����ɮ0nh��BM�/.#l��xmά�@��$������� ���.Y�=D�� ��������ԫ����/��WJ��>�1C��!�3>�38#~�G���\�A@���rI�Nl�P��g�8(������Wï����=W_�Si;h��&�eی?J�[�B�:�E˘��-��o�|hoN�p~���q̸��;yw$�]��{�a9=�S����J���$Y�������mC�L���7ó������p�����Q��?_AշVP��C�WH�?������w����u���������Ѵ��QW��$�;�Øw�,{5�,\w0v�m�/�ڣؾ:��A3�<�]agv�U6�X\�i �g�Ɨ	>L2�<mgl7.�B����Ȟ��Ȃ��RE\��#�e ��^и�����	����Gp���(���W}������A��_����u����;�G2����-��W���_��:oˢ�S�wV5Uϳ���ᢖ������om�vu[�9 {z�'� ���g�p��A{�
�C���x� �:�[z��b��˷�^n7�_��4ZMI�Z��Yض2l�e@6s8�q�TT�ǘ]�W�ܫ{���7�E����7I���۞���+�� ���T�58H�ڒ���q`@���N3I��>�%��2?t#�\c����O��̤=3��y���Ԑ[i�N���&eL�>?����@4TK�Ա������c���l�w�4�Ŋ��`[6����.[�{b*-"�����"S����[�CO�1��,�DsrY���>�4@����G�������tx�K����~���p8�T
���������J�v�!KU���������
`�?����������O���D%��<�e<��q�ǹ�	2��<�cYZ�8�g�����v�G�d��E��zv~(�����?�ϯ��u��qYj;�����Ę�'�cQ>+fA����.YӠ�}�����?�%��b�%�0�����}�?5�!�YSR���ô�����'�1����\5f�ǎ�8�Лd�v[�C��-���^P���� �S	���u�J�[Tq�ߑ�gI��U����w�����j���)�xG������$��0�W��x��PF����G��S��������o ��6����l\¦Ծl�\�U�+��;(k��VD��[%�9�3�߷ǰ���������.��5�ބW�%{���}���d����m�ę�t�OL�*sl2u�Φ�����Љg�.�-/�Ӕ18�sw�6�eF8�.�^�I�/F#�g�t��r��]�k�I��h���;r�&	�a�[�z�[�Q�y���[���]�C{��+;Ց5K�3�b1YM��hѼW
�Dh�7n�S4&�7�'9l&Zb3:�]��K�mm՝�j�!pG������ӋL�)4���t[ve����n����j���*�n������_k�Z��Fp�@!���͒�����������������_�� �$�n����C��>*���!�
H�������U �a�/��������������������K�~��c�����)��+�'q�>��@���*���������_���ﺨY�a9D̀���׮�ă��������r����]���@�G%�����j�����@���J�����?��[8~
$�q������@���dH�@����������WB�c!5�B��h��*�?���� �����&��!j����������Z��!������
�?T������?��?�����Y�@�]@���������������C���C�}@�?��C���:��)����G�����2�d��A�_�n����S�>p�Cu���q5�>q���S8�B��MR�U X>������#x�|��<��i��_�Q�����b	��k�/��`��������%�ow���O������ǵ�ד�m�ҥ�bn_�61���d�:�ZJ�C�ڐ��P4eQNrf9�pg8˲��\��ky�m�Q���s��̅i�"�w�v������n��>�^ 6�x�)��#ɘo�khw���~���?��������
��������@B����6�����5����������ǯ��e0�F���F�ay�Grg1�a�����9��;u�}��F�2����,�t�1"�����b��9��ǝ�%љ8��}ә%�0l�����������kFN��Q�o��ʘ�}/h������oE p��?������@�����`��`��?�������$�����(����y���������Rw;��|`7���'^J��7���W��gow�v��Jn�����>��Ԯ���Q�l(���gi�3��	�!h,T��$�:Ym�D�{ɄŇ=уa�/؅X������4/i/awtI�#�̌�����$��N�v�=]:���o9-�0��g� %jK���ąh`o�IO�4�d���XR|�(�C7��u��<fN����L�ѳ�a�@4TK�:��w��b�/$�O�>��{��[�{g7��G���-]]L%m8)b#���F��r�7BA$�ɮ3e�qO-��f�p{�?���O���F�׷�����8G@��>���>��ǯ?E�p�+���������J�����F7h�B�*����?�$����$N��i��*�F���z�N��J��q��:�G_5�U�V��ɲ^���0����m�)w4A�s�2�*p�����-E�_����b�h?gܔ�z�������a������s?^R~�ל�U�ɗ�o��N]z����.����-sy�Z��um�d$��$��iդ�YWC��[C���P�3ty��ؕ=P���&kU8�m|�S�L�'$r-[KH�l�v��{f6)�&�r��xަV%<�_�[�/�#��\��RyO�7o�R�]]/k!%3�������������!��4��D�$V*���f�=Ր���,��f��J��f�b��<�[z����2'fGT$UL%r�Km^"��X��H0�x"�#q:�����D��n$Z"�Nӓ
�<Ï��/�=�V��jS�W�����+������^@��1w�P���j��3����s1OФ'�T@xׇi6b�����88�b��|6`<���a���@!���������W	���_a�X��Q����1���?�{�c�=���␜�R����ޮ�խ`�+7�����G�o��w����_����������
����C�*����?�����W	o��z�-��}��i9ꏲTH���r�)��]��U���֗�:�`�r�������v?�gr������!9/���K��%�}_�Ϣ���XRI�:ܑ��nC�����v@ONz(�	���5�i�k|��<`Ey�GA�k�٥Ō�'�t��&���oi?�y���� ���j�N%�������q����E-9_�Y���'�6[���=����4�,ӶO����kmVS۲��vn����f�v��*@@��~tu���(������hNvr���Jb �2֘k�9�=\�G860&������(���0ґz|֦�^yXЭ�8js�a�+�8ۻ���PHT���>�e�^���~�A�����7���S*���A��8V2�����t��b��4J�ղZ��=z��e�"T��-x�R���7D��������A��=~���X�מ�M�Rk�� 9T����d/�j���{�y��<��}]�$��Q����[?������1D	���@�_�����/����I�/��K ��g�����R���L�i����`W�?C@��
�5��'�ڧ��S�����5B����ݻ��~��ð����Ɨ�>�'vtY���n���GN��ԬN���plU���jo��۪��E��и�\!?:uu��B��\�ӧ�k
Cq��W���:/���I)��0p�b'�[���S)�Z�Y��}��@�˱�z��$.�$��F8�z�Y�huە;�[v����X�?ݶZM!�a�e�M6:��(���,���>��F���C��X�)[b���V�Ȍ�m���n!7��#����UW?>a�+�lS���I�cH�������p�	J��+W2�h�ngM�v����Z�Y�j���k�,0����(�_*��Km���W�o��ȃ��o���?� ��_W!��+ ��o�������C�����C.����O��ߩ �?!��?!���A��U��XC ���������0��R�0��r�_����?�����7��7�����y�����5����Ob���\�?s����)!��J��!' ��Ϟ�o����o*Ȋ��q��� ���=��U���������������?yc��?���"#�������?��� ���_�B�a7���#d���(${@���/�_�����������쐋��������!���?���?��?迴��Bd���[���a�?3���"#�"�������O�� ��� ���������T�����3�����r������J��H��
���!�?3@�?��C���"��a�'#d����17��v�����_���_����CJ���4�����9���`�fV��Mun�ʔa0e�IZ7M���{(��*S�1����O��G��D_�����^����<�âB]�^���Z��w�J�&Y��/����H�q���@�k��imЧn	�j�?E|�E�T۫LE�W�FV���M���t����A��H����3K=�I|�DZ�1WHl��=U��+Jk��KBw9i�&���X�̛G��T�X�S��x�ꦲn�!�?�f����p��y@����C���C�����8̺�y�����ό�8�j�N�u�1:�0$b�Ũ��8jY�j��](.vִ����hٞ�ڃ�Z��Mۊ�5>�)�!1q���T��Ӫ�tt[7�sE�Djq��|�PƮ:'��o�>PO���k�����!��_Wt�WlԿr���_�꿠�꿠��@�e4�0C�B�Q���+��K���{��g��nY�/z��Q{fq�H�g�_N��ӟ���/�ʉ�L�=m�}��ٗ�m���6�Y��鍻�Q��,<��Z3V�Ѽ���"S�ø81�qq��9GNōW�%�F��;uL���J�{%����~�;�P_hUn�dɳ:;��'_��l���Q�����k�|�D��W��)�u���{���Zpp."��X�����MA����J��R�!/4�k>�ugO����]�J��ܛB���6�uu�F�7?Lˡ�#�X>� �������o��$����;�t��%Lm�*�k���%��p
����[��O@�GN������?�*���$��������37���4��?�x��}B� ��Ϛ��o�z���O��R�u�9����3��F���������"�Y��=��?s�'o�@�o*���d�H�����1��?� �?��#�?�/r���㿠�RA��V���߷������!7��?f�\���u�/��������C}�����=�Í�-��M蹩_���t�?�H�>�D�c�GRX��X����#�0���~$��+j'Mnx��m_�~/����~�%'�׺�	k̎�i�X�:���"�C���ye���kL֦����:3�n�4˯5C<)
3����4Y���Ȟ2J�~������"7�~UM8��E-��R�&T�͖��ñ:�{���剭#��~Ygb�����{�^�pl`Lr9i����(���0ґz|֦�^yXЭ�8js�a�+�8ۻ���PHT���>�e�^�πA.���g���ߋE��n�{�����r��0������/a U�"�������* �/���/���6�'a�'#d���Ϻ)��߷���S�F���8 ����!�?3|+��V������v����8�T)-kМ�������Q$Y���^_�V�zt��)�Q ���O5 �}�+��OvܺJ���\Uu�f6�2�y�~SV�-b�ИR�PD��2^=jӠg7K#%t�P+�Q{���EE�#��5 HR�gj ����j z�X��WE�"xl��}5\�mC�]�o�Q@m1�����h]^樠�nI��Rܡؽ*w:jGah4]��	�mE����a�#���������ߧE��n����������%���c	�?���
��j�1MZ��JY5�%L#L
�hR�)�$�\1(\71��L�����J�!�4�1x��﯌<����?!�?���?̌�;�[�әǜ����xK��^?��zm�\��4�/���̈́@�{��{�*����N�����"-)9�=�����~�Ч�C�aG	��$���:�&�i�,����X���C����!��?Y*��s����/;��!�'3d��O� �a`�Mq���C��~f��w������p�C��T����[�Pl�)�q�v������Gj;l	��d��s��Gx�>�/<��5�J#F�t~l��]��{��%M']�&���h���K�������$����G������"�_P����꿠��`��_��?��A�E�@�e�o�q��,�Y�5lݣ��c�D[���s�R������g��@.��(.�`��:ܪj��;�WT�(h������K[4F�˧
�DK�bVf�#M�'��^��J�24O�ڨ�^�h5�<+��mn����s��$:�S٨�}�y����h�q�a���1�@b�C������ȭ����QkX��e���Rd^CX�ܔ�`�Ҕ��rX�(�7�8>���<�4��DY�����ʵO��z��8�#�ӄ���)5��I:ό��k�Z!��qe͎-s`n"�j���)}��Jذ�=>����Z�6������i��	���{�m����u}�7�#c���$]b�����;���1|54
�:��>����:fԃ��Â�r=��ȋ��;����3�"���Cr���1��Q��~9��T��	���a��]ȭ6��������:�В|F�V]�X]N��F|�O��'���_l��Z�.�����}c���O��P|�����ߘ��i�y��q;A0I�����o��j��jj`#��
��	�`:~����,x��u�J����΃$0��c��j���#'y��������s�uL'�%g�|U+��Q�w�o��;~|��?"U��ۻ��(��B�O�������c�������������
�������h��ϊ�?�}�waF򬟟��39C|���=�^��p\��E�O8��+|�'7�q��P;z��2���ON!���0��������A!�c��w��Va3�����Yp�`g>�����>��~���'���֚��b�����߷��	V��}uo|ug.=_O�x�������=l|�?n�_�ϧ��)�����(,��/98in�u�~n<��	����b���~��q��Ň�7Ʒ{�ǎ �>6���e�?����Va$�x^���OJx���Y$��A��֟z��	              �K��F��� � 