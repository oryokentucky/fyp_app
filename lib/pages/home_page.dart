import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp_app/auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_app/pages/login_register_page.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final User? user = Auth().currentUser;

  Future<void> signOut(BuildContext context) async {
    await Auth().signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  final List<Map<String, String>> furnitureCatalog = [
    {
      'name': 'Modern Sofa',
      'price': 'RM 1200',
      'category': 'Living Room',
      'imageUrl':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRTAqSSUkZeLE1-Lw_M2-wLFmHiksxo5fJr0w&s',
    },
    {
      'name': 'Classic Bed',
      'price': 'RM 2500',
      'category': 'Bedroom',
      'imageUrl':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRIaU8pUvlMhgtSmrHpZBxdjlz-6ExjoCzwNQ&s',
    },
    {
      'name': 'Wooden Dining Table',
      'price': 'RM 1800',
      'category': 'Dining Room',
      'imageUrl':
          'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAkGBxMTEhUTExMWFRUXGBcZGBgWGBgdGRcYHxgeHRsYHRcaHSggGBolHRcdITEhJSkrLi4uGB8zODMtNygtLisBCgoKDg0OGxAQGy0mICUwLS0tLS0tLS0tLS0tNS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLf/AABEIAOEA4QMBIgACEQEDEQH/xAAcAAEAAwEBAQEBAAAAAAAAAAAABQYHBAgDAgH/xABNEAABAwICBQgFCQQHBwUAAAABAAIDBBESIQUGMUFRBxMiYXGBkaEyQlKxwRRicoKSosLR8CMzsuEkJUNTs9LxFTRjZHSDw3OTo+Ly/8QAGQEAAwEBAQAAAAAAAAAAAAAAAAIDBAEF/8QAKhEAAgIBAwQCAQMFAAAAAAAAAAECEQMSITEEIjJBE1GRM0JDFCNhcYH/2gAMAwEAAhEDEQA/ANxREQAREQAREQAREQAREQAREQAREQAREQAREQAREQAREQAREQAREQAREQAREQBV9ZteIKJ/NyMkc61xhDbHZvLr7+HFUuu5ZyDaKjHa+X8IZ8V+eW+i/awSj1mlh+qSfxBUvQupVZWNEkMV4ySMZcwNuDY7XXPglstGMaTZM13K9pBx6DYIx1McT4ufbyURV6/aTfmat4B3NDGeBY0HzXLrNqrLRSNZOW3e3E3mySLXIsSQLHLr2hduoGrsNbWCCZzwzmnv6BAJcHNAaSWnKzjssdmaS7dFdMUrojptMTy/vJ5H324nud7yV6L1ZqOco6Z5zLoYie0sF1k3KZqjT0LKc0zXNxGQPLnOcT6GHabDadnFaRycz49G0p4Mw/ZcW/hTolkaatFkRETEQiIgAiIgAiIgDKeW2pcx9JhuBhnuRfI3jts7/BZ5S6w1UZynmb1c4+3dmtE5Z6gtlpRewLZAdm8tA2hd+gOTuhnpYpHsfjc27i2Rwubn1c2jsAss1NzaRujKMcUXIz6HXquYQPlD+xziSfG6loOUmtH9oD9JrCPJoKgteNCx0tY+CIuLG4LF5BObGu2gD2l06o6purZDGJQwhjn3LLjJzRb0hvd5Lqk7oZxhp1NbE83lVq2+k2F3cQfDEFPaqcpEtXUxU5gY0PvdwLsgBfIKuaY5L54IZJefic2NjnuycHFrRc2FiL2Gy65eSKkJ0gx3sskP3SPinUndMlKGNwcom7IiKpkCIiACIiACIiACIiAKLys0LpaePDa4fYXIAzs7a4gDJhX55KwYKV8MrmAiVzmYXtcCxzWZ3aTbpYslNa+Q4qUn2XtPj0fxLJJZHtOWXYPiFlyZfjmbMWL5cdWWTlyiBFNKCCP2jSR9UjPxVW5L58Gk6Y7n84w98biPNoXfDpmZosHv7CSfJ1xZfun02WSMl5iBz2m4fzbWvB44mWz7ULNFuyjwSjHSXTlgpsVJG72ZB7iT/CvtyQTX0c1vsSSt+9i/GqzpfXNtVFzM8bg297sLbg2I3i28qR1D0tTUcT4w97w+QydJoBaS0AjLI+iOCqpJyszyxyUKaNLRQ8Ws1MRcyBoG0usAO03yUjRVccrBJE9r2O2OaQQc7GxHWLKtkGmuT7oiIOBERABERAGQctwxT0zRtwO83f8A1Wj6oMtRU4/4YWc8rcv9OiHCAHxfJ/lWlarf7nT/APpRnxaCpQ82aMn6cTFeUpw/2lUH5zPKJg+CtfJHH+2ebWtA2/a5wP4VUNdHY9ITnhK4eFh8Ff8Akpgs6c/NiHnJ+QSxXd+S2R/2vwWTX6XDo+pO27MNhvxENt5rPuR+n/pb3WteEnsu/Z5q88o77ULx7Tox4PDvwqt8k9NhlmPCOMeP/wCVVrdMzxdY2aWiImIhERABFz1FYxm058Bt/kq/pLWcC4jzPUcvtfkg7RY5qhrdp7t6j4dNtdI2Nrb3Nr3yG/hns3KmzaQfJ6Ry4DZ/PvUzqqzFNf2Wk95y9110KLciIuHCL1nixUk4te0bnAdbRiHuWA1ekW82JH4mtJOYz2X/ACXpCVgcC07CCD2FeaK6C0D43bY5nt77G/n71l6iK2bNvSSe6RPVmg6qFuKWCQN24rYmgcS5lwPFRLqkDYSt10I8VOjYS7ZLTMDr/OiAdfxKwilgPNlrm2cyM5Hi1xF/d25KeSCgrLYcssjafo+jXi+d1KUZvsUNVSFrWkAHptBvf0Te9rb9in9GaIlxOAy+lcb9xAN1yO/BSTo4NPAmJ+zIXtvyzvt6lfuSzT7W6LhBDnODphYDL988jM9RVHr4xhlYSMTWuB2ZGxHfmpTk1lIog3hJJl22d+JVxPchmjcUaJPp+V3osDR4n8vJcb6uQm5e+/b+S4Wyi+YIXW0HcVezMor0dMWlZW+uT2gH+a6o9YHj0mNPZcfmozEd4B7k5xu9vgu2Dgiej0/GdrXDz/XguqLSsLtkgHbl71VzgO9f35ODsPxRqF+P6KHyqzYtKCxGEQRt6vTcfxrYdAMw00DeEUQ8GBZnrFSux3aA7o2/WaslBXTsjYA92TRt6W7rupwa1Mrki3CP+DHNP6UvXzm1wZpD4vK13kjmEkE0gFum1n2W3/Gsv0poWEzOLcYOI7HXub8HZrR+TavZTUzoi1x/aOcXC20hu6+4DiuY09W4+avj2O7lcqwykYCbYpR32jefyXx5KnB/ymQeiXRtH1Q6/vUFyx1ZqIqdsLSQHPLr2BBs0N2nPIu2Kf5HowyiIJAeZCS24uOi0WI7bqib1URaSxWXxEROQCIufSFSIopJDsYxzz2NaT8EAYuKwz6RmcTsmlI+g0kN7sgp4ZhUnURrnvPrPsGji4ucFYqHSokklja0gQuLHE26TgSHWtuBAz33UMKpN/bNmbmvpHZpTSMdOwSSYrOJDbC+JwFyBu2cTwVt5OqgywumLcOItsL3t0b2vv8ASWecrUpb8jp98cGIj50jgPfGfFafqHTYKOMccR87DyaFRSbk19EZxSgn7ZYURE5EhdNayRU7xG++MtDhfJtiSPS3eiVg2nHXlrLCwMxlte+T3F2R3jNbrrnQMkpnuLQXNALXWGIdIXsdoyWGacgAmeG7Hxgg91visueX7Wbuliq1IuGq1a99BGMROAPZa5ys42sL22WVdq2kucSLHCR8T/Cvlqjp0RRPjdaxfizuNoA27Act6kK4tcLtJN8s7b8to27VCclJJGmEdLbK9MbwOBvtYbgXI6IGy4vs4haDq6xwJLJAQbZZjyNx5qhvjJik+iPuuPwVy1YxGNjjvY09ewLuNbnMj2K7pon5VUtOR6fiTf4qW5LS00sgcbHnbjsMbB7wVE6bbasn6/ixpXZyVzNwTssDYxnPrxjb9VUW0hHvAvrab2XAr9uY4bl+Gtb1jzH5roF9xv3/AAKspENJ8hKd/wCu9frGOH68kMo9Zo9ydA7CR2prFo/haOP671/Oa4L9c0dxv2FfN7LbR8EWGkhNMPeH5Xt2A+V1MR1Fmi/DsUPpFri/K9kdWuAtn3qdbspvSIuqkY55u3f1FT+hIWYMsszxHvVbdISbljT3Z+KmtF1TQwC2HqB/NJBNMpNqj9aw0ePDbO2ea+egKQsizG1xPmvlpSpBIs8A235ealdFEiNud8txuqKT1E2lpo+0VZK30ZHDqxG3guyHT9Q3aQ76QHwsud0nEA9q+Vmnd4Kmoi8ZNRa0u9aIHra63kQfeubWbWON9JM0NcHOYW2NrdLI5g8CVXtKaTiiB6QJGZGwNHFx3KsV1fzsQlxXBJDRsGVxex6wkyzqDO48dzR16lhkcwkOQY573dkcTnrm5O4S+NmLN80pLuu7g138N1xSVPNUlQ7jE9n/ALrmRH7rnHuVo5O6MNkhxZNhjdI7qs2x83XS4PFD5/Jlb1/q+f0u9vqsexg7GNBcPtYlumiKfm4ImeyxoPbbPzXnrVMGq0k15Gckjnu7XyZ+Tj4L0gqY+GyefZqP0giIqGc4tNQY6eZg2ujeB1HCbHxXnutaf2RO3psPVa+XmvSBC89aQisZm/3c7j4Gx9yzdQuDZ0j5IvVyidJJJG1mMhuK3UDa4tt9NTPyZzASWFu/0gRcZ26io7QVaKXSAc42YbtcepzcvvW8FoWl5I5oHOaWuyuCLG1jnn2XWXT7NjlWxSXR5ub1EeIB+JXVoHT5ZBGOAw5gEZHZcWI8V82tONp4ht+03b77Li0UILPikkEb2yPAubAt3bcjnfK90O/QKvZ9tI1POzmSwGItGWzJlvwr+cmkgbPOwkAuaLXNr4XEZcfSX2noubc25uMQII3g5fFVB0xinfh9p3he6rBvkSVVRt4BG1fQFZbFrDUBoMb3N6r3H2TkpLR2vct7SRsk+gS1wH0cwfAKiyL2ScH6NC508b9ufvX85wcLdihqLWCCX1jGeEgt97Z5qTFtoNxxGzxCqmmSaaZ9w4bneK/fPOA23HiFyr+XQ6Oqz8TTNJ6TM+IyX4kja4ZOI+kLjxX7LuP6/Nfh0bezsSOI6ZySaNcdliPmn4HJfgUxaLG/1hZdmG2w+8HxX0+UOG25HWl0tcDOSZA1dDiOY8FM0sBY0C9rBfRr43HNoB/W8KO0zrDFCC2IiR44G7GnrO89Q8l2MmnuLJJokqiuEbcT3ADif1cnqVb0prCZOjGMA4+sf8vvUDJUyzuxOOI+DR1AblLw6uzClmq3jDFFE94v/aENJAb1E2GLryuqqiLsg9NfuHddh3k+ZsugZQwN+YXeOfxVQq658rrvN7DIDYBwA3K21+Tg0eoxjPL+ayZp6kzXihpaOfSrsTIYRskkZi62tuSOz9oD9VW81HMaNrpt72tp2223fk+x6muDu5VRrcVWzLKNj3d5OC32WqT5QKrm6SkpQc3B1VJ9e7YvuYsuoLTHtgZn3T/6dHIlo/HVOlIyYCe+1vx+S3JULke0TzNHzhHSkN+7b73EfVV9VIqkQyO5MIiJiYWG620nNVtWNznl9vpDEfetyWVcpFLasv7bGn3t/Cs/U+Jq6TzozPTsZBjfxbb6zTb4qzVGr9RFEypaw809jXiSIktwuAIxb2jO2YG1QVR06e+9paT39Bw+0LrRdW6vn9XaqIm7oYqiM9gaXt7sLgO5SxxUnRoyycYplQkktY8Cbdvpj3Kr6yODZZB7Ra4dhab+YUtoSox07CdrRY/UNvNpC4NY6Nz3Q4GlznAsAaLklp4d5XIKpUdk7ifzVSe7Xtvk10Z7ic+zYv3T6LfPXthjw45HkNxGzc2YszY5WB3KW0fqzJTUj3yx4ZnvGYkvaPAegWAYQ7FniBO2yip5yyqjkY4tP7MhzSQRnYkEZjJPKrFxt0WjSupNbTtJdDzjR60V3jwAxDtLVnlXFdxt2rVItbq+nOU/OAerMA4fayd95ZnV0bmkYH5Dcdn67k2hLxEWR/uPtoqolvhxuIG45+/Yp1ukZGC7HW42JHuX11P0MKmGpe6Rkb6duMMsCZGhribDFlbDtA37lHtljmBjiN5DezQ04jYXNm2zta+ROxJJfaHi4vhkvSa3zNI6TXj2ZMj9V4t53Vgo9aYn+m1zDv8AWA8M/JZU1hxWO0HO3ne29S1EwkZG1vL8kytLkHzwatTVMcg/Zva7sIv4bV9S1ZgS5uYIPZ+tqnWV1VAbFzj1Hpt8T0h5I+SuQ0WXHCuLSulYqZuOV+G+wD0ndQG/3Ks6R11kZHYRtDzcYrmw+qd/eqNUSyTPLnOc97jtOZP5DqXdRzRuWLTetktSCxg5qI8LY3DgXD3DzTRmjXvwMa1zicmsaLuPdu/WxR1NGyIXccT9w4fritQ1J1uoIG4RDKx7vSlOF5d2kWIHzQLJYvU9uDk+xfbJvVPUNsQD6kBz90YzY36Xtnq2du1dHK5Uc3ompt63Ns7nStB+7dWHR+m6ea3NTMcT6t7O+ybHyVI5dqjDo+Nn95UMB7Ax7ve0LRSUXRlTcpqzDKNuKRjeLmjxNvirhKcTy7cXX7gqjoj9+w8DfwBI8wrfG2w6gCT2b/K6wzW6R6MXs2dWr1DzsxZ/evZHfgxo6bgerpn6qh9L1R0hpAlubZZQGAboWdFoA3XY0G3FxU1NMaaiqJibPLRTx2/vZrmVwO0FsYcf+4F+uRTQ/PVZmcLtiGXbkffhP1StXNIyXScjcdGUgiiZGPVaB2nee83K6kRXMgREQAVA5ToelC/iHDwII/iKv6qPKXDemY72ZB4Fp+IClmVwZbA6yIxijF3TRfOkA7HdIe4rv1Q1m+Sw1cJikmNQzAxkYuceFwOQz2O3A+io6+CsfwcGO8LX+K/Gj6ww1hscPSe0/RNyB5jwWaLaaZtklJNM7dFaAnpYQZ8Ixu9AG7m9G3StkL5ZAnYvzWSmMRzDbDLFIewOwuHfYq0aVjLqYv4WI93xVbqmYmvbuc11u0jEPO6Vu3Z2C7aLzpyMvgk4AYvDP4LJ9ORkNYeAc3vGz3LTdB6UEtLFfMmNrXdZAwu8wVnunYegQfVe0/A+ZToVbF5p6ZksUcntsa77TQfio6s0KzgvtqXLjoouLcTPsuIH3bKSniTWJRR67RDRmAuDRNeaOqiqWNDnxOJAdexu0tINs9jjnxtt2K5VdMCq5pTRwOdkymI4Fu0rr5oytgvNo90lWbMDGDpknZhnjs9zbm1rA33b18tEcm1Y6J08uCA2LmwuJc7Dt6Txk05ZCx67FZpIGg2yJ8v5r01qFK52jqRziXEwx3JJJPR2kk3KqqlySbcODAKWZsovA/EbEkZhwG+4ts6xkrhUbR+ti1n/AGXS0/Ozshhhc5pMkjWMYSNt3OAF+OayCM5NvuHwWTqI6aNfTz12VjW8ftR1A+/+S5KKnt0htI8Oxd+sQ/bAH2R7ypDRujbta47wD5LuOmtxsja4ItmjS4381I0lJh3KahpepdHyVO2RSPhSx3Ga+2k6Xn4xHMXSRtN2gud0Ta1xnllwX6jbYqQa24XDpnulNBxU8jHRufd2LouscIG+9r79hvvUxRC7MR4jwb8MiFF6Yl5yofwYcA7tv3iVO8xZjYj1B3fbEfDNcatjN1GvsheUaUsFLTbCyIzyD/izG+EjiyNrB3rV+R7RHM0IcRZ0hz7tv3i5YbX176ytMkhxOkkBcRsIaANg+YwL07oCk5qmhj3tY2/0rXd5krRDdmbLtFIkERFUzhERABQOvEGOil6sLvBwJ8rqeXHpiDHBKz2o3jxaUslaaGi6kmec9KttUMPtMc3+L8worTLf6Q+w9LAQON2Ad+xS+mndOJ3zreNvyXFWSYJoJT6rY397HX+CyR4R6D5ZMaD0i805YXEjZY52sfEbOK/QNsHUG+WILadYNVaaoDpDGGy2J5xnRcTbLFbJ/eCsUxXDe03+1f4rmSDi9zuLIprZHTqhc4oxtY9wtwzv8Vy6y09nzt6ifxD+JRmj6x8VdJhJAJJy2Z57DcKX0rPzry42u5tjb6IHuahB7O3kwlvTzN9mW/YHNHxaVYqp6oOoGkWw/KMbg1toznxBcO/0l06V1oL7tj6I4nafy/WxdlsxUrZKaW0pHF6Ts9zRtPcqbpTSr5b+q3gD7zvXRojQFTXzYIIzI4ek4mzGdb3nZ2bTuBW16l8mtPR4ZZbT1AzDnDoRn5jOPzjc8LXsnxxctxckow29nnR8Btdeo+Twf1ZRf9PF/AF5lnd0Rxy9y9O6gj+rKH/poP8ADarY3ZnzKqKzyz1pjgpwMw+axbewIDSRcb7GxH+lqSXkdys3LnJ/uLeMjz4YB+JVyobv61k6l9xr6VdllZ05L+2v80K16Md+yj+g3+EKmadbimA2bF96fWB8ZAIDmjIbiB7j4IhwNNF+iauqNiq1DrRC71sJ4OFvPZ5qep60G2aeybR0Tw71y1VYIYpJD6rSR1ncO82CkA4EWVO1wq7R83xcL9gz99kezhD6CZie0k5XxOJ4DO577eK69Yqp3MgNuHOdmBtAIc53cAPBctALQuPtYYx2PcA7ydfuVuY1jNGaSqXNGMR8wxx2tMnQdbgTjaP9U8VbOTlRR9RKLna6JhF7kD7Tg0+TivUq87cilLjrw7c3Pwa4+8tXolWgjNldsIiJyQREQAREQB57130DPTGz4nBvOARuAu1+dmgEesb+jt6lWdMC7Yz1PafG3xXqpeYNY4MGNn93LI3wP8lnnBRWxsxZHJ7npTRk3OQRP9uNjvFoPxXnx4sCOFx34b/BaLTcolNRaNpA93Oz/J4hzTCLghgHTdsZs7epZvJPju/ZicXZbrsv8VzPvR3pk02fLnnc7LTw0gnqJXtLH2JfG0MAcBhtYEm5LjhG8bxJ6Z0LNSOjZUYBI9mMtYSQ2+MYbnaejuyz2narlyPuvU1+Xq0xH/y39wXx5Xmf0mA8YyPAu/zI0r47DW/l0mNU7DzjgOJA8ch2rTtTOSmWa0tbihj2iIZSv+l/dj730dq4uReFrtKPxNBwwzObcA4XCSNocOBs5wv848VvaaME3qYuXK49qOXRmjoqeMRQxtjY3Y1osOs9ZO8nMrqRFcyHkKryaD1j3FeodRRbRtCP+Vp/8Jq8v6QPRt1r1LqeLUFGP+Wg/wAJqnjL53wZry8Sf0jRrfnSH78KhZ5v13KX5bzetoBwDj4yM/JQFTkO4rJ1PkjX0v6ZX9Km78twHkLKf5UtR49HMjlZM57JJMGB7RiacLnXxiwI6NrWBz2lQLmY52D2ntHiQtN5fdGVM0FOYYXysjfI6QsFyzogNJaOkRm7MCwtnZVwwTW5LNkakqMXp6d7mue1rnMZbE4NJay97Yjazb4Ta+2xUjo2dzB0XFvZs8Ni1zkI0LLDTTSyxlgnLMGIWc5rQelhOYaS42vt27LE2fTfJ/QVNyYeaeb9OHoG/EtAwuPW5pTPC/Rz+oV1JGN0WssjD0gHDqyP5E+CjdY9JtnkDmAgYRe/tb8u4K86b5JqhgJppGzDOzXdB/UMzgceu7VmukaV8Ur45Glj2ZOadoNr/EHvSqDXI+qL4ZMQt6FO32nOf9lpHveFPazTc3oIN31FYL/RazF/FGPFQR/ext9iC/eXAfgXXyiT4aLRsPFtRM4fSkAYfDEniTnuyxcgNH05ZODXebmj/wAZW1LM+Qqkw0j3+0WDwBf/AOVaYrR4M0+QiIuihERABERABecOUOLDU1bbf27nfbJP4l6PWDcqlKRW1VvWETx2YWg+YKnk4LYH3EpyQatUEzRPMRLVAu/YvtaMBxwvDD+8uLOxG4F7WBFzX9YhaqqRwqJfDnHfBd2ouq8lbRGaOQCWGZzAD0Tk1rmlsgzabP337QojSUMjZJWzX50OGPEbnFizuRtOd79alPhbF8danuXbkdf/AEur64ac+DpPzX15ZMpaY/Nf5EfmuLkfePl0w40rD4SW+KkOWdvSpT1S/wAUab+MT+Yq/Iq7+tZR/wACb/FiW8LBOR7LSzuuGYfeYfgt0rq2OGN0sr2xsaLuc4gADtKpDgnm8j7rPuULlNiosUFPhmqthH9nCfnkbXfMGfG2V6vrPyh1VfJ8j0WyQNdcY2i0sg3lt/3LOLjY5j0d9n1A5MYqPDPUYZqkZjfHEfmg+k/557gM79u+BNNK5Hn2WN1sTtp47fDcvWGqo/oVL/08P+G1UTSXI1BJO17Z5GwlxdJEQC4/NZJ6o7Q49a0umgbGxrGCzWNDWjg0CwGfUERT9nckk6oxrlnf/WNKOETD4zO/yqvzuy/XBTHLDnpWL5sEP+LKVAPdcD9bljz+Zv6dVA5NEZ1lOONRC3xkaPivTa816rw49I0o/wCZid9mQO+C9KLRh4MnU8oIiKxnC8v621HPaQqncaiRo7GvwDyaF6fc6wJOwLynRSc5Mx5zxPxnvdiKSbL4VyyYBvUTHc1sbfFpd+JQeuNLNHUOjlfjLGsLQHEhjHtEjWWIFj08wMrneprR4u+Y8ZS37IaFD6UqOeq7l2Il7cbib3IIvnwAFu5Iins9B8mFHzej4xa2IuPgcA8mK2KN1apjHSQMIsREy/0i0E+ZKklVGV8hERdOBERABERABV/WfVGnrc5AWyWw84ywdhvfCbggjhcZbtpvYEXGrOptcEfoPQsFJEIqeMMbe5ttc6wGJzjm51gBc8ANgWM6/wAWGvqt1yx3aC1hv4k+C3ZRentAQVbMEzL5ZOGT29jt3ZsNswlnG1Q+OemVswvQVJNLMPkwcJ44ecDo3YX4Wua1wB9bN46JyIvkdi7tY9Pz1TYmVDRjhLhiALS7EW3D49jXDBu47BZaDqrqK+jref51r4mwvjbkQ84ntdmNgtg2g532BRXLHStBp5A0BxxhzgM3WLMIJ32zt2lT0PSXWROZnWqen2UFaah7XPAZI0Nba7nEdEXOwX2nd1qXhp9I6wT4nnm6djttjzMXU0f20tuvec2ggKH1S0VHU6Thp5rmN7n4g02JDYnvtcZgEtANs89y9HUlKyJjY42NYxos1rQA1o4ADYmgrQmWWl7ckVqtqvT0EeCBuZtjkdYvkPzjw4NFgL5BTaIqkG7CIiDhjvKxoOpNa2qERdBzbGl7c8BBdfENrR0tuzrVPabOAPUtx5QHW0dUfQA8XAfFYZbYexY88akeh00rj/o46DRctRUtip3Bsr3PwEuLQCA53pAEtybt7FaIte9MaKcI6+F0kd7Ay7+ptQ24ccr9LEexfLk0gvpWnPs86e/mnj4reZ4WvaWvaHNIsWuAII4EHIhWxRqJDNPuKbq1yoaPq7N5zmJD6k1mi/U/0T2XB6ldQVnOsvI9RT3fTXpZPmDFET1xE9H6pb2FUt1NprQ2YLn049aO8sNvnMIvGOJs36RVLaJVGXBs2tVXzVFVS+xBK4doYSPNea9AsvK3qB91vir7pflTFVQTQSQ4ZZGYQ5hvGbkXuCcTeje3pbNqpOrUV5Du6Nuy5Bv4ApJOyuOLinZ3aChLi0EZyyh1vpv2La6nk90e+pbVcwGyNdjIYSGPdxdH6JzNzkL77rPeSLV51TzdVLfm4zi+nLixAD5rbgnuHG21poolN7hEROTCIiACIiACIiACIiACIiACqPKNoKapijMLQ50biS29iQR6t8ibgZf6K3IuNWqOxdOzEOTfVqpdpNtSYyyKBz8bngtu4xOZgaCLlwL7nhbPOwO3oiIqkdnLU7CIi6KEREAVjlKdbRtR/wBseMrFiLXWI7lvmuGiX1VJLAwgOdhILr2u14dYkAkejwWJ6d0NNTuDZo3MOdidjvouGTuO3JZc6do2dNJU0SnJU2+kmdUch+6B8VuKzPkm1Wewmtlu3GwtibxYSCZD24Rh6rneLaYtEFSM+R3IIiJiZkXLZoOlhhjnjhayaSYNJZ0Q5uBziXNHRJuG52vntVb5JqTHWR3FxiuexrHn32Wj8qmqdRXxw8w5t4i9xjcbF9wAMLtgIscjYHFtFs43ko1Umhc+eeN0RGJjGO2nZd3ZlYcbnqvNp6i6kvj5NHpqZkbQyNjWNF7NaAGi5ubAZDMk96+qIqEAiIgAiIgAiIgAiIgAiIgAiIgAiIgAiIgAiIgAiIgAvlU0zJGlkjGvadrXAFp7QcivqiAP4Av6iIAIiIAIiIAIiIAIiIAIiIAIiIAIiIAIiIAIiIAIiIAIiIAIiIAIiIAIiIAIiIAIiIAIiIAIiIAIiIAIiIAIiIA//9k=',
    },
    {
      'name': 'Luxury Carpet',
      'price': 'RM 450',
      'category': 'Living Room',
      'imageUrl':
          'data:image/jpeg;base64,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',
    },
  ];

  Widget _buildFurnitureCard(Map<String, String> item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      child: Row(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(item['imageUrl']!),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name']!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item['price']!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Category: ${item['category']}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      print('${item['name']} added to cart');
                    },
                    child: const Text('Add to Cart'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[300],
        title: const Text(
          'RoomScape',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          Row(
            children: [
              Text(
                user?.email ?? 'User',
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () {
                  // Navigate to profile
                  print('Profile icon clicked');
                },
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for furniture...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.lightBlue),
                ),
              ),
            ),
          ),

          // Carousel Slider
          CarouselSlider(
            options: CarouselOptions(
              height: 200,
              autoPlay: true,
              viewportFraction: 0.4,
              enlargeCenterPage: true,
            ),
            items: furnitureCatalog.map((item) {
              return Builder(
                builder: (BuildContext context) {
                  return Card(
                    elevation: 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          item['imageUrl']!,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item['name']!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          item['price']!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }).toList(),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.lightBlue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Join Our Loyalty Program!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.lightBlue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Earn points with every purchase and redeem exciting rewards. Sign up today and start saving!',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
          // Furniture List
          Expanded(
            child: ListView.builder(
              itemCount: furnitureCatalog.length,
              itemBuilder: (context, index) {
                return _buildFurnitureCard(furnitureCatalog[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
