export CLASSPATH=:/home/luis/Downloads/antlr-3.3-complete.jar
echo -e "\033[0;32m \n---------o Conteúdo do arquivo a ser testado o--------\n\033[0m"
cat ./antlr/testIn.txt
echo -e "\033[0;32m \n----------------o Resultado do teste o----------------\n\033[0m"
cd ./classes/br/ufpb/iged/csed/
java Test < ./../../../../../antlr/testIn.txt
echo -e "\n"

