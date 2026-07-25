import io
import qrcode


class QRService:
    @staticmethod
    def generate_qr(url: str) -> bytes:
        qr = qrcode.QRCode(
            version=1,
            box_size=10,
            border=4,
        )

        qr.add_data(url)
        qr.make(fit=True)

        image = qr.make_image(fill_color="black", back_color="white")

        buffer = io.BytesIO()
        image.save(buffer, format="PNG")

        return buffer.getvalue()