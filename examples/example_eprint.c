#include "nthink.h"

int main(int argc, char **argv)
{
    if (argc < 2)
    {
        char *err_msg = "error: this program requires arguments\n";
        
        eprint(err_msg);
        eprint_at(err_msg);

        return 1;
    }

    return 0;
}
