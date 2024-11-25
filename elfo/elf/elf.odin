package elf

import "core:fmt"

Elf :: struct {
    header: Header,
}

Header :: struct {
    ident   : Header_Ident,
    type    : Header_Type,
    machine : Header_Machine,
    version : Header_Version,
    entry   : Header_Entry,
    phoff   : Header_Phoff,
}

Header_Ident :: struct {
    class          : Header_Ident_Class,
    data_endianess : Header_Ident_Data_Endianess,
    version        : Header_Ident_Version,
    os_abi         : Header_Ident_OS_ABI,
    abi_version    : Header_Ident_ABI_Version,
}

Header_Ident_Class :: enum byte {
    Bits32 = 1,
    Bits64 = 2,
}

Header_Ident_Data_Endianess :: enum byte {
    Little_Endian = 1,
    Big_Endian    = 2,
}

Header_Ident_Version :: distinct u32

Header_Ident_OS_ABI :: enum byte {
    System_V = 0x00,
    HP_UX,
    Net_BSD,
    Linux,
    GNU_Hurd,
    Solaris  = 0x06,
    AIX,
    IRIX,
    Free_BSD,
    Tru64,
    Novell_Modesto,
    Open_BSD,
    Open_VMS,
    NonStop_Kernel,
    AROS,
    Fenix_OS,
    Nuxi_CloudABI,
    Stratus_Technologies_OpenVOS,
}

Header_Ident_ABI_Version :: distinct byte
Header_Type    :: distinct u16
Header_Machine :: distinct u16

header_machine_descriptions := map[Header_Machine]string {
    0x00 = "No specific instruction set",
    0x01 = "AT&T WE 32100",
    0x02 = "SPARC",
    0x03 = "x86",
    0x04 = "Motorola 68000 (M68k)",
    0x05 = "Motorola 88000 (M88k)",
    0x06 = "Intel MCU",
    0x07 = "Intel 80860",
    0x08 = "MIPS",
    0x09 = "IBM System/370",
    0x0A = "MIPS RS3000 Little-endian",
    //0x0B - 0x0E 	Reserved for future use
    0x0F = "Hewlett-Packard PA-RISC",
    0x13 = "Intel 80960",
    0x14 = "PowerPC",
    0x15 = "PowerPC (64-bit)",
    0x16 = "S390, including S390x",
    0x17 = "IBM SPU/SPC",
    // 0x18 - 0x23 	Reserved for future use
    0x24 = "NEC V800",
    0x25 = "Fujitsu FR20",
    0x26 = "TRW RH-32",
    0x27 = "Motorola RCE",
    0x28 = "Arm (up to Armv7/AArch32)",
    0x29 = "Digital Alpha",
    0x2A = "SuperH",
    0x2B = "SPARC Version 9",
    0x2C = "Siemens TriCore embedded processor",
    0x2D = "Argonaut RISC Core",
    0x2E = "Hitachi H8/300",
    0x2F = "Hitachi H8/300H",
    0x30 = "Hitachi H8S",
    0x31 = "Hitachi H8/500",
    0x32 = "IA-64",
    0x33 = "Stanford MIPS-X",
    0x34 = "Motorola ColdFire",
    0x35 = "Motorola M68HC12",
    0x36 = "Fujitsu MMA Multimedia Accelerator",
    0x37 = "Siemens PCP",
    0x38 = "Sony nCPU embedded RISC processor",
    0x39 = "Denso NDR1 microprocessor",
    0x3A = "Motorola Star*Core processor",
    0x3B = "Toyota ME16 processor",
    0x3C = "STMicroelectronics ST100 processor",
    0x3D = "Advanced Logic Corp. TinyJ embedded processor family",
    0x3E = "AMD x86-64",
    0x3F = "Sony DSP Processor",
    0x40 = "Digital Equipment Corp. PDP-10",
    0x41 = "Digital Equipment Corp. PDP-11",
    0x42 = "Siemens FX66 microcontroller",
    0x43 = "STMicroelectronics ST9+ 8/16 bit microcontroller",
    0x44 = "STMicroelectronics ST7 8-bit microcontroller",
    0x45 = "Motorola MC68HC16 Microcontroller",
    0x46 = "Motorola MC68HC11 Microcontroller",
    0x47 = "Motorola MC68HC08 Microcontroller",
    0x48 = "Motorola MC68HC05 Microcontroller",
    0x49 = "Silicon Graphics SVx",
    0x4A = "STMicroelectronics ST19 8-bit microcontroller",
    0x4B = "Digital VAX",
    0x4C = "Axis Communications 32-bit embedded processor",
    0x4D = "Infineon Technologies 32-bit embedded processor",
    0x4E = "Element 14 64-bit DSP Processor",
    0x4F = "LSI Logic 16-bit DSP Processor",
    0x8C = "TMS320C6000 Family",
    0xAF = "MCST Elbrus e2k",
    0xB7 = "Arm 64-bits (Armv8/AArch64)",
    0xDC = "Zilog Z80",
    0xF3 = "RISC-V",
    0xF7 = "Berkeley Packet Filter",
    0x101 = "WDC 65C816",
    0x102 = "LoongArch ",
}

Header_Version :: distinct u32

Header_Entry_32 :: distinct u32
Header_Entry_64 :: distinct u64
Header_Entry    :: union { Header_Entry_32, Header_Entry_64 }

Header_Phoff_32 :: distinct u32
Header_Phoff_64 :: distinct u64
Header_Phoff    :: union { Header_Phoff_32, Header_Phoff_64 }

println :: proc(self: ^Elf) {

    // ELF Header:
    fmt.println("ELF Header:")

    ident_println(self)
    type_println(self)

    //Machine:                           Advanced Micro Devices X86-64
    fmt.println("  Machine:", header_machine_descriptions[self.header.machine])

    //Version:                           0x1
    fmt.printf("  Version: 0x%X\n", self.header.version)

    //Entry point address:               0x4010a0
    fmt.printf("  Entry point address: 0x%x\n", self.header.entry)

    //Start of program headers:          64 (bytes into file)
    fmt.println("  Start of program headers:", self.header.phoff, "(bytes into file)")

    //Start of section headers:          544472 (bytes into file)
    //Flags:                             0x0
    //Size of this header:               64 (bytes)
    //Size of program headers:           56 (bytes)
    //Number of program headers:         14
    //Size of section headers:           64 (bytes)
    //Number of section headers:         39
    //Section header string table index: 38
}

@private
ident_println :: proc(self: ^Elf) {

    //Magic:   7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00
    //ommited

    //Class:                             ELF64
    fmt.println("  Ident Class:", self.header.ident.class)

    //Data:                              2's complement, little endian
    fmt.println("  Ident Data (Endianess):", self.header.ident.data_endianess)

    //Version:                           1 (current)
    fmt.println("  Ident Version:", self.header.ident.version)

    //OS/ABI:                            UNIX - System V
    fmt.println("  Ident OS/ABI:", self.header.ident.os_abi)

    //ABI Version:                       0
    fmt.println("  Ident ABI Version:", self.header.ident.abi_version)
}

@private
type_println :: proc(self: ^Elf) {
    //Type:                              EXEC (Executable file)
    fmt.print("  Type: ")
    if self.header.type == 0x00 {
        fmt.println("Unknown (ET_NONE)")
    } else if self.header.type == 0x1 {
        fmt.println("Relocatable file (ET_REL)")
    } else if self.header.type == 0x2 {
        fmt.println("Executable file (ET_EXEC)")
    } else if self.header.type == 0x3 {
        fmt.println("Shared object (ET_DYN)")
    } else if self.header.type == 0x4 {
        fmt.println("Core file (ET_CORE)")
    } else if 0xFE00 <= self.header.type && self.header.type <= 0xFEFF {
        fmt.println("Reserved inclusive range. Operating system specific")
    } else if 0xFF00 <= self.header.type && self.header.type <= 0xFFFF {
        fmt.println("Reserved inclusive range. Processor specific")
    } else {
        fmt.println("Unknown")
    }
}
