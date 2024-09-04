| pin name | I/O | Description |
| -------- | ----| ----------- |
| Bend | In | Set high to select bend mode |
| ServoCK | In | servo SPI clock(data read on rising edge) |
| ServoDa | In | servo SPI data(16bit signed speed) |
| ServoSS | In | servo SPI SS(set low during transit) |
| Fault | Out | 1 = voltage or motor error(not overheat) |
| Fan | Out | 1 = close to overheat |
| Ready | Out | 1 = parked or overheated |
| Park | In | 1 = power up, 0 = power down |

# Timing
- after ServoSS pulled LOW, there must be at least 0.4us before togglig ServoCK, otherwise 
Fault will be asserted.
- after ServoSS pulled HIGH, the speed just transmitted needs at least 20us to fully take 
effect.
