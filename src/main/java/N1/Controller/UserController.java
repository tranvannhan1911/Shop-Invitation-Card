package N1.Controller;

import java.nio.charset.StandardCharsets;
import java.security.Principal;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

import N1.DTO.*;
import N1.Service.*;
import N1.entity.*;

@Controller
@RequestMapping("/user")
public class UserController {
    @Autowired
	private SanPhamService sanPhamService;

	@Autowired
	private NguoiDungService nguoiDungService;

	@Autowired
	private LoaiSanPhamService loaiSanPhamService;

	@Autowired
	private HoaDonService hoaDonService;

	@Autowired
    private GioHangService gioHangService;
    
    @Autowired
    private CTHoaDonService ctHoaDonService;

    @RequestMapping({ "/gio-hang", "/cart" })
	public String showShoppingCartPage(Model model, Principal principal) {
		List<LoaiSanPham> dsLoaiSanPham = loaiSanPhamService.findAll();
		model.addAttribute("dsLoaiSanPham", dsLoaiSanPham);
		model.addAttribute("isCategoryPage", 0);

		NguoiDung nguoiDung = null; 
		int soLuongSpGh = 0;
		if (principal != null) {
			String email = principal.getName();
			nguoiDung = nguoiDungService.findNguoiDungByEmail(email);
			soLuongSpGh = gioHangService.getNumOfSanPhamInGioHangByEmail(email);
		}
		
		model.addAttribute("nguoiDung", nguoiDung);
		model.addAttribute("soLuongSpGh", soLuongSpGh);
		
		List<SanPham> dsSanPham = new ArrayList<SanPham>();
		model.addAttribute("dsSanPham", dsSanPham);

		return "user/shopping-cart";
	}

    @RequestMapping({ "/thanh-toan/{maND}", "/checkout/{maND}" })
	public String showCheckoutPage(Model model, @PathVariable int maND,  Principal principal) {
		NguoiDung nguoiDungLogin = null; 
		int soLuongSpGh = 0;
		if (principal != null) {
			String email = principal.getName();
			nguoiDungLogin = nguoiDungService.findNguoiDungByEmail(email);
			soLuongSpGh = gioHangService.getNumOfSanPhamInGioHangByEmail(email);
		}
		model.addAttribute("nguoiDung", nguoiDungLogin);
		model.addAttribute("soLuongSpGh", soLuongSpGh);
		
		List<LoaiSanPham> dsLoaiSanPham = loaiSanPhamService.findAll();
		model.addAttribute("dsLoaiSanPham", dsLoaiSanPham);
		
		NguoiDung nguoiDung = nguoiDungService.findNguoiDungById(maND);
		model.addAttribute("nguoiDung", nguoiDung);
		
		List<SanPhamMua> dsSanPhamMua = sanPhamService.getSanPhamMua(maND);
		int soLuong=dsSanPhamMua.size();
		model.addAttribute("dsSanPhamMua", dsSanPhamMua);
		model.addAttribute("soLuong", soLuong);
		double tongTienHang = 0;
		for (SanPhamMua sanPhamMua : dsSanPhamMua) {
			tongTienHang += sanPhamMua.getThanhTien();
		}
		double giamGia = tongTienHang * 0.05;
		double tongThanhToan = tongTienHang - tongTienHang * 0.05;
		model.addAttribute("tongTienHang", tongTienHang);
		model.addAttribute("giamGia", giamGia);
		model.addAttribute("tongThanhToan", tongThanhToan);
		model.addAttribute("isCategoryPage", 0);
		
		return "user/checkout";
	}

	@RequestMapping(value = "/orders/success", method = RequestMethod.POST)
	public String createHoaDon(@RequestParam("maND") int userId,PayLoadCreateOrder payLoadCreateOrder, Model model) {
		List<LoaiSanPham> dsLoaiSanPham = loaiSanPhamService.findAll();
		model.addAttribute("dsLoaiSanPham", dsLoaiSanPham);
		String diaChi=payLoadCreateOrder.getDiaChi();
				byte[] bytes = diaChi.getBytes(StandardCharsets.ISO_8859_1);
				diaChi = new String(bytes, StandardCharsets.UTF_8);
		// 1 Lay user tu context security
		// 1.1 lay chi tiet user
		NguoiDung nguoiDung = nguoiDungService.findNguoiDungById(userId);
		// 2 Lay thong tin gio hang tu user
		List<ChiTietHoaDon> chiTietHoaDons = new ArrayList<ChiTietHoaDon>();
		List<SanPhamMua> dsSanPhamMua = sanPhamService.getSanPhamMua(userId);
		// có danh sách sản phẩm mua -> mã sp, số lượng , thành tiền
		double tongTienHang = 0;
		int tongSoLuong = 0;
		for (SanPhamMua sanPhamMua : dsSanPhamMua) {
			tongTienHang += sanPhamMua.getThanhTien();
			tongSoLuong += sanPhamMua.getSoLuong();
		}
		double tongThanhToan = tongTienHang - tongTienHang * 0.05;
		// 3 Tien hanh tao hoa don, tao chi tiet hoa don-> Luu thanh cong
		Date ngayLHD = new Date();
		Date ngayGiaoHang = new Date(ngayLHD.getTime() + (3 * 1000 * 60 * 60 * 24));
		String trangThaiDonHang = "Chưa thanh toán";
		HoaDon hoaDon = new HoaDon(ngayLHD, tongThanhToan, tongSoLuong, trangThaiDonHang, ngayGiaoHang,
				diaChi, nguoiDung);
		HoaDon hoadonSave = hoaDonService.addHoaDon(hoaDon);
		dsSanPhamMua.forEach(e -> {
			SanPham sanPham = sanPhamService.getSanPhamByIdSanPham(e.getMaSp());
			ChiTietHoaDon cthd = new ChiTietHoaDon(hoadonSave, sanPham, e.getSoLuong(), e.getGiaSp());
			ctHoaDonService.addChiTietHoaDon(cthd);
			chiTietHoaDons.add(cthd);
		});
		// 4 Xoa gio hang cua khach hang
		gioHangService.deleteGioHangByIdNguoiDung(userId);
		// 5 Tao trang chi tiet hoa don( truyen du lieu hoa don vua tao duoc qua trang
		// do)
		model.addAttribute("hoadonThanhToan", hoadonSave);
		model.addAttribute("chiTietHoaDons", chiTietHoaDons);
		model.addAttribute("tongTienHang", tongTienHang);
		model.addAttribute("giamGia", tongTienHang * 0.05);
		model.addAttribute("isCategoryPage", 0);
		return "user/detail-order";
	}
	@RequestMapping(value = {"/show-order" })
	public String showHoaDonChiTiet(@RequestParam("maHD") int maHD, Model model, Principal principal) {
		NguoiDung nguoiDungLogin = null; 
		int soLuongSpGh = 0;
		if (principal != null) {
			String email = principal.getName();
			nguoiDungLogin = nguoiDungService.findNguoiDungByEmail(email);
			soLuongSpGh = gioHangService.getNumOfSanPhamInGioHangByEmail(email);
		}
		model.addAttribute("nguoiDung", nguoiDungLogin);
		model.addAttribute("soLuongSpGh", soLuongSpGh);
		
		List<LoaiSanPham> dsLoaiSanPham = loaiSanPhamService.findAll();
		model.addAttribute("dsLoaiSanPham", dsLoaiSanPham);
		// Tìm hóa đơn theo mã hóa đơn
		System.out.println("maHD"+ maHD);
		HoaDon hoaDon=hoaDonService.findHoaDonById(maHD);
		System.out.println(hoaDon.toString());
		List<ChiTietHoaDon> cthds=new ArrayList<ChiTietHoaDon>();
		cthds=ctHoaDonService.getDSCTHoaDonByMaHD(hoaDon.getMaHD());
		double tongTienHang=0;
		for (ChiTietHoaDon chiTietHoaDon : cthds) {
			tongTienHang=tongTienHang+chiTietHoaDon.getThanhTien();
		}
		model.addAttribute("hoadonThanhToan", hoaDon);
		model.addAttribute("chiTietHoaDons", cthds);
		model.addAttribute("tongTienHang", tongTienHang);
		model.addAttribute("giamGia", tongTienHang * 0.05);
		
		model.addAttribute("isCategoryPage", 0);
		return "user/show-my-order";
	}
	
	@RequestMapping(value = {"/order/history", "/lich-su-mua-hang"})
	public String showHoaDonByNguoiDung( @RequestParam("maND") int userId, Model model, Principal principal) {
		NguoiDung nguoiDungLogin = null; 
		int soLuongSpGh = 0;
		if (principal != null) {
			String email = principal.getName();
			nguoiDungLogin = nguoiDungService.findNguoiDungByEmail(email);
			soLuongSpGh = gioHangService.getNumOfSanPhamInGioHangByEmail(email);
		}
		model.addAttribute("nguoiDung", nguoiDungLogin);
		model.addAttribute("soLuongSpGh", soLuongSpGh);
		
		List<LoaiSanPham> dsLoaiSanPham = loaiSanPhamService.findAll();
		model.addAttribute("dsLoaiSanPham", dsLoaiSanPham);
		List<HoaDon> hoaDons=hoaDonService.findHoaDonByUserId(userId);
		hoaDons.forEach(e->{
		List<ChiTietHoaDon> cthds=new ArrayList<ChiTietHoaDon>();
		cthds=ctHoaDonService.getDSCTHoaDonByMaHD(e.getMaHD());
		e.setDsCTHoaDon(cthds);
		});
				
		model.addAttribute("hoadons",hoaDons);
		model.addAttribute("isCategoryPage", 0);
		return "user/history";
	}
}
