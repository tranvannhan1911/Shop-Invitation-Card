package N1.DAO;

import java.util.List;

import N1.DTO.SanPhamMua;
import N1.entity.*;

public interface GioHangDAO {
	public void deleteGioHangByIdNguoiDung(int maND);
	
	public void deleteGioHangByIdNguoiDungAndSanPhamMuas(int maND, List<SanPhamMua> sanPhamMuas);
	
	public void deleteGioHangByIdNguoiDungAndIdSanPham(int maND, int idSanPham);

	public List<GioHang> getDSGioHang();

	public List<GioHang> findAll();

	public List<GioHang> findAll(int page);

	public int getNumberOfPage();

	public GioHang addGioHang(GioHang gioHang);

	public List<GioHang> findGioHangByUserId(int maND);

	public boolean saveGioHang(GioHang gioHang);
	
	public int getNumOfSanPhamInGioHangByEmail(String email);
}
