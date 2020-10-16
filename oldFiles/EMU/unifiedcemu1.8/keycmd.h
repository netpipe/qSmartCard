#include <iostream>
#include <sstream>
#include <fstream>
#include <streambuf>

void keycmd (void);
void init_keyboard(void);
void close_keyboard(void);
extern int on[17];
struct teebuf: std::streambuf {
teebuf(std::streambuf* sb1, std::streambuf* sb2):
m_sb1(sb1), m_sb2(sb2)
{
}
private:
int_type overflow(int_type c) {
if (!traits_type::eq_int_type(c, traits_type::eof()))
{
m_sb1->sputc(c);
m_sb2->sputc(c);
}
return traits_type::not_eof(c);
}
int sync() {
m_sb1->pubsync();
m_sb2->pubsync();
return 0;
}
std::streambuf* m_sb1;
std::streambuf* m_sb2;
};
