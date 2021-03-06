USE [master]
GO

CREATE DATABASE [web_invitation_cards]
GO

USE [web_invitation_cards]
GO

CREATE TABLE [dbo].[ChucVu]
(
	[maChucVu] [INT] IDENTITY(1,1) NOT NULL,
	[tenChucVu] [NVARCHAR](100) NOT NULL DEFAULT (N''),
	CONSTRAINT PK_ChucVu PRIMARY KEY([maChucVu])
)
GO

CREATE TABLE [dbo].[TaiKhoan]
(
	[maTaiKhoan] [INT] IDENTITY(1,1) NOT NULL,
	[tenDangNhap] [VARCHAR](255) NOT NULL,
	[matKhau] [VARCHAR](100) NOT NULL,
	[tinhTrang] [INT] NOT NULL DEFAULT (1),
	[maChucVu] [INT] NOT NULL,
	CONSTRAINT PK_TaiKhoan PRIMARY KEY([maTaiKhoan]),
	CONSTRAINT [UK_TaiKhoan_tenDangNhap] UNIQUE ([tenDangNhap])
)
GO

CREATE TABLE [dbo].[NguoiDung]
(
	[maND] [INT] IDENTITY(1,1) NOT NULL,
	[diaChi] [NTEXT] NULL DEFAULT (N''),
	[sdt] [VARCHAR](10) NULL DEFAULT (''),
	[tenND] [NVARCHAR](125) NOT NULL,
	[maTaiKhoan] [INT] NOT NULL,
	[hinhAnh] Text NULL DEFAULT (N'https://cdn.icon-icons.com/icons2/1378/PNG/512/avatardefault_92824.png'),
	CONSTRAINT PK_NguoiDung PRIMARY KEY([maND]),
	CONSTRAINT [UK_TaiKhoan_NguoiDung] UNIQUE ([maTaiKhoan])
)
GO

CREATE TABLE [dbo].[HoaDon]
(
	[maHD] [INT] IDENTITY(1,1) NOT NULL,
	[diaChiGiaoHang] [NTEXT] NULL DEFAULT (N''),
	-- trạng thái giao hàng
	-- đã giao - dựa theo ngày giao
	-- chưa giao
	[ngayGiaoHang] [DATETIME] NULL,
	[ngayLHD] [DATETIME] NOT NULL DEFAULT (getdate()),
	[tongSoLuong] [INT] NOT NULL DEFAULT (0) CHECK([tongSoLuong]>=0),
	[tongTien] [MONEY] NOT NULL DEFAULT (0) CHECK([tongTien]>=0),
	-- thanh toán | chưa thanh toán
	[trangThaiDonHang] [NVARCHAR](100) NOT NULL DEFAULT (N'Chưa thanh toán'),
	[maKH] [INT] NOT NULL,
	CONSTRAINT PK_HoaDon PRIMARY KEY([maHD])
)
GO

CREATE TABLE [dbo].[SanPham]
(
	[maSp] [INT] IDENTITY(1,1) NOT NULL,
	[giaSP] [MONEY] NOT NULL DEFAULT (0) CHECK  ([giaSP]>=0),
	[hinhAnh] [TEXT] NULL,
	[tenSp] [NVARCHAR](255) NOT NULL,
	[moTa] NTEXT NOT NULL DEFAULT (N''),
	[giamGia] float NOT NULL DEFAULT (0) CHECK  ([giamGia]>=0),
	[giaMua] [MONEY] NOT NULL DEFAULT (0) CHECK  ([giaMua]>=0),
	CONSTRAINT PK_SanPham PRIMARY KEY([maSp])
)
GO

CREATE TABLE [dbo].[ChiTietHoaDon]
(
	[maHD] [INT] NOT NULL,
	[maSp] [INT] NOT NULL,
	[giaBan] [MONEY] NULL DEFAULT (0) CHECK([giaBan]>=0),
	[soLuong] [INT] NULL DEFAULT (1) CHECK([soLuong]>=1),
	CONSTRAINT PK_ChiTietHoaDon PRIMARY KEY([maHD], [maSp])
)
GO

CREATE TABLE [dbo].[LoaiSanPham]
(
	[maLSP] [INT] IDENTITY(1,1) NOT NULL,
	[tenLSP] [NVARCHAR](100) NOT NULL,
	[hinhAnh] Text NULL DEFAULT (N''),
	CONSTRAINT PK_LoaiSanPham PRIMARY KEY([maLSP])
)
GO

CREATE TABLE [dbo].[ChiTietLoaiSP]
(
	[maLSP] [INT] NOT NULL,
	[maSp] [INT] NOT NULL,
	CONSTRAINT PK_ChiTietLoaiSP PRIMARY KEY([maLSP], [maSp])
)
GO

CREATE TABLE [dbo].[DanhGia]
(
	[maDanhGia] [INT] IDENTITY(1,1) NOT NULL,
	[noiDung] [NTEXT] NOT NULL DEFAULT (N''),
	[thoiGian] [DATETIME] NOT NULL DEFAULT (getdate()),
	[xepHang] [INT] NOT NULL DEFAULT (0) CHECK([xepHang]>=0 OR [xepHang]<=5),
	[maND] [INT] NULL,
	[maSP] [INT] NULL,
	CONSTRAINT PK_DanhGia PRIMARY KEY([maDanhGia])
)

CREATE TABLE [dbo].[GioHang]
(
	[maND] [INT] NOT NULL,
	[maSp] [INT] NOT NULL,
	[soLuong] [INT] NULL DEFAULT (1) CHECK([soLuong]>=1),
	CONSTRAINT PK_GioHang PRIMARY KEY([maND], [maSp])
)
GO

ALTER TABLE [dbo].[ChiTietHoaDon]  WITH CHECK ADD  CONSTRAINT [FK_ChiTietHoaDon_HoaDon] FOREIGN KEY([maHD])
REFERENCES [dbo].[HoaDon] ([maHD])
GO
ALTER TABLE [dbo].[ChiTietHoaDon] CHECK CONSTRAINT [FK_ChiTietHoaDon_HoaDon]
GO

ALTER TABLE [dbo].[ChiTietHoaDon]  WITH CHECK ADD  CONSTRAINT [FK_ChiTietHoaDon_SanPham] FOREIGN KEY([maSp])
REFERENCES [dbo].[SanPham] ([maSp])
GO
ALTER TABLE [dbo].[ChiTietHoaDon] CHECK CONSTRAINT [FK_ChiTietHoaDon_SanPham]
GO

ALTER TABLE [dbo].[ChiTietLoaiSP]  WITH CHECK ADD  CONSTRAINT [FK_ChiTietLoaiSP_LoaiSanPham] FOREIGN KEY([maLSP])
REFERENCES [dbo].[LoaiSanPham] ([maLSP])
GO
ALTER TABLE [dbo].[ChiTietLoaiSP] CHECK CONSTRAINT [FK_ChiTietLoaiSP_LoaiSanPham]
GO

ALTER TABLE [dbo].[ChiTietLoaiSP]  WITH CHECK ADD  CONSTRAINT [FK_ChiTietLoaiSP_SanPham] FOREIGN KEY([maSp])
REFERENCES [dbo].[SanPham] ([maSp])
GO
ALTER TABLE [dbo].[ChiTietLoaiSP] CHECK CONSTRAINT [FK_ChiTietLoaiSP_SanPham]
GO

ALTER TABLE [dbo].[DanhGia]  WITH CHECK ADD  CONSTRAINT [FK_DanhGia_SanPham] FOREIGN KEY([maSP])
REFERENCES [dbo].[SanPham] ([maSp])
GO
ALTER TABLE [dbo].[DanhGia] CHECK CONSTRAINT [FK_DanhGia_SanPham]
GO

ALTER TABLE [dbo].[DanhGia]  WITH CHECK ADD  CONSTRAINT [FK_DanhGia_NguoiDung] FOREIGN KEY([maND])
REFERENCES [dbo].[NguoiDung] ([maND])
GO
ALTER TABLE [dbo].[DanhGia] CHECK CONSTRAINT [FK_DanhGia_NguoiDung]
GO

ALTER TABLE [dbo].[GioHang]  WITH CHECK ADD  CONSTRAINT [FK_GioHang_SanPham] FOREIGN KEY([maSp])
REFERENCES [dbo].[SanPham] ([maSp])
GO
ALTER TABLE [dbo].[GioHang] CHECK CONSTRAINT [FK_GioHang_SanPham]
GO

ALTER TABLE [dbo].[GioHang]  WITH CHECK ADD  CONSTRAINT [FK_GioHang_NguoiDung] FOREIGN KEY([maND])
REFERENCES [dbo].[NguoiDung] ([maND])
GO
ALTER TABLE [dbo].[GioHang] CHECK CONSTRAINT [FK_GioHang_NguoiDung]
GO

ALTER TABLE [dbo].[HoaDon]  WITH CHECK ADD  CONSTRAINT [FK_HoaDon_NguoiDung] FOREIGN KEY([maKH])
REFERENCES [dbo].[NguoiDung] ([maND])
GO
ALTER TABLE [dbo].[HoaDon] CHECK CONSTRAINT [FK_HoaDon_NguoiDung]
GO

ALTER TABLE [dbo].[NguoiDung]  WITH CHECK ADD  CONSTRAINT [FK_NguoiDung_TaiKhoan] FOREIGN KEY([maTaiKhoan])
REFERENCES [dbo].[TaiKhoan] ([maTaiKhoan])
GO
ALTER TABLE [dbo].[NguoiDung] CHECK CONSTRAINT [FK_NguoiDung_TaiKhoan]
GO

ALTER TABLE [dbo].[TaiKhoan]  WITH CHECK ADD  CONSTRAINT [FK_TaiKhoan_ChucVu] FOREIGN KEY([maChucVu])
REFERENCES [dbo].[ChucVu] ([maChucVu])
GO
ALTER TABLE [dbo].[TaiKhoan] CHECK CONSTRAINT [FK_TaiKhoan_ChucVu]
GO

-- chuyển đổi kí tự có dấu thành không dấu
CREATE FUNCTION [dbo].[fuConvertToUnsign] ( @strInput NVARCHAR(4000) ) 
RETURNS NVARCHAR(4000) 
AS 
BEGIN
    IF @strInput IS NULL RETURN @strInput
    IF @strInput = '' RETURN @strInput
    DECLARE @RT NVARCHAR(4000)
    DECLARE @SIGN_CHARS NCHAR(136)
    DECLARE @UNSIGN_CHARS NCHAR (136)
    SET @SIGN_CHARS = N'ăâđêôơưàảãạáằẳẵặắầẩẫậấèẻẽẹéềểễệế ìỉĩịíòỏõọóồổỗộốờởỡợớùủũụúừửữựứỳỷỹỵý ĂÂĐÊÔƠƯÀẢÃẠÁẰẲẴẶẮẦẨẪẬẤÈẺẼẸÉỀỂỄỆẾÌỈĨỊÍ ÒỎÕỌÓỒỔỖỘỐỜỞỠỢỚÙỦŨỤÚỪỬỮỰỨỲỶỸỴÝ' +NCHAR(272)+ NCHAR(208)
    SET @UNSIGN_CHARS = N'aadeoouaaaaaaaaaaaaaaaeeeeeeeeee iiiiiooooooooooooooouuuuuuuuuuyyyyy AADEOOUAAAAAAAAAAAAAAAEEEEEEEEEEIIIII OOOOOOOOOOOOOOOUUUUUUUUUUYYYYYDD'
    DECLARE @COUNTER INT
    DECLARE @COUNTER1 INT
    SET @COUNTER = 1
    WHILE (@COUNTER <=LEN(@strInput)) BEGIN
        SET @COUNTER1 = 1
        WHILE (@COUNTER1 <=LEN(@SIGN_CHARS)+1) BEGIN
            IF UNICODE(SUBSTRING(@SIGN_CHARS, @COUNTER1,1)) = UNICODE(SUBSTRING(@strInput,@COUNTER ,1) ) BEGIN
                IF @COUNTER=1 SET @strInput = SUBSTRING(@UNSIGN_CHARS, @COUNTER1,1) + SUBSTRING(@strInput, @COUNTER+1,LEN(@strInput)-1) ELSE SET @strInput = SUBSTRING(@strInput, 1, @COUNTER-1) +SUBSTRING(@UNSIGN_CHARS, @COUNTER1,1) + SUBSTRING(@strInput, @COUNTER+1,LEN(@strInput)- @COUNTER)
                BREAK
            END
            SET @COUNTER1 = @COUNTER1 +1
        END
        SET @COUNTER = @COUNTER +1
    END
    SET @strInput = replace(@strInput,' ','-')
    RETURN @strInput
END
GO

USE [master]
GO
