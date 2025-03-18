#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <inttypes.h>

int main()
{
    FILE* file = fopen("Maripo.wav", "rb");
    if( file == NULL ){
        fprintf(stderr, "Error al abrir archivo\n");
        exit(-1);
    }

    unsigned char byte = 0;
    while( fread(&byte, 1, 1, file) >= 1 ){
        if( byte == 'd' ){
            fread(&byte, 1, 1, file);
            if( byte == 'a'){
                break;
            }
        }
    }
    fread(&byte, 1, 1, file);
    fread(&byte, 1, 1, file);

    int value = 0;
    fread(&value, sizeof(value), 1, file);
    printf("%d\n", value);
    int16_t datum = 0;
    int16_t maximum = 0;
    int16_t minimum = 0;
    while( fread(&datum, sizeof(datum), 1, file) == 1 ){
        if(datum > maximum){
            maximum = datum;
        }
        if(datum < minimum){
            minimum = datum;
        }
    }

    printf("Max: %d, %" PRId16 "\nMin: %d, %" PRId16 "\n", (((int)0 + 32767) * 100 / 4095), (((int)minimum + 32761) * 100 / 4095), maximum, minimum);

    fclose(file);

    return 0;
}