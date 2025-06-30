import 'package:json_annotation/json_annotation.dart';
import 'appointment_model.dart';

part 'invoice_detail_model.g.dart';

@JsonSerializable(explicitToJson: true)
class InvoiceDetail {
  final int? invoiceDetailId;
  final int? invoiceId;
  final Appointment appointment;
  final double unitPrice;
  final int? employeeId;
  final int? storeServiceId;

  InvoiceDetail({
    this.invoiceDetailId,
    this.invoiceId,
    required this.appointment,
    required this.unitPrice,
    this.employeeId,
    this.storeServiceId,
  });

  factory InvoiceDetail.fromJson(Map<String, dynamic> json) =>
      _$InvoiceDetailFromJson(json);
  Map<String, dynamic> toJson() => _$InvoiceDetailToJson(this);
}
