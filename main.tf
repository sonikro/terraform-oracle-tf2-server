# ===========================================
# DATA SOURCES
# ===========================================

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

locals {
  availability_domain = var.availability_domain != "" ? var.availability_domain : data.oci_identity_availability_domains.ads.availability_domains[0].name
}

# ===========================================
# VIRTUAL CLOUD NETWORK (VCN)
# ===========================================

resource "oci_core_virtual_network" "vcn" {
  compartment_id = var.compartment_id
  cidr_block     = var.vcn_cidr_block
  display_name   = "${var.name_prefix}-vcn"
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags
}

# ===========================================
# INTERNET GATEWAY
# ===========================================

resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.compartment_id
  display_name   = "${var.name_prefix}-igw"
  vcn_id         = oci_core_virtual_network.vcn.id
  enabled        = true
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags
}

# ===========================================
# ROUTE TABLE
# ===========================================

resource "oci_core_route_table" "public_rt" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "${var.name_prefix}-public-rt"
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw.id
  }
}

# ===========================================
# PUBLIC SUBNET
# ===========================================

resource "oci_core_subnet" "public_subnet" {
  compartment_id             = var.compartment_id
  availability_domain        = local.availability_domain
  cidr_block                 = var.subnet_cidr_block
  display_name               = "${var.name_prefix}-public-subnet"
  vcn_id                     = oci_core_virtual_network.vcn.id
  route_table_id             = oci_core_route_table.public_rt.id
  prohibit_public_ip_on_vnic = false
  freeform_tags              = var.freeform_tags
  defined_tags               = var.defined_tags
}

# ===========================================
# NETWORK SECURITY GROUP
# ===========================================

resource "oci_core_network_security_group" "nsg" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "${var.name_prefix}-nsg"
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags
}

# ===========================================
# SECURITY RULES - TF2 PORTS (27015-27020 range)
# ===========================================

# TF2 Server TCP - Ports 27015-27020
resource "oci_core_network_security_group_security_rule" "tcp_range" {
  network_security_group_id = oci_core_network_security_group.nsg.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source_type               = "CIDR_BLOCK"
  source                    = "0.0.0.0/0"
  description               = "TF2 Server TCP ports 27015-27020"

  tcp_options {
    destination_port_range {
      min = 27015
      max = 27020
    }
  }
}

# TF2 Server UDP - Ports 27015-27020
resource "oci_core_network_security_group_security_rule" "udp_range" {
  network_security_group_id = oci_core_network_security_group.nsg.id
  direction                 = "INGRESS"
  protocol                  = "17" # UDP
  source_type               = "CIDR_BLOCK"
  source                    = "0.0.0.0/0"
  description               = "TF2 Server UDP ports 27015-27020"

  udp_options {
    destination_port_range {
      min = 27015
      max = 27020
    }
  }
}

# ===========================================
# EGRESS RULE - ALLOW ALL OUTBOUND
# ===========================================

resource "oci_core_network_security_group_security_rule" "egress_all" {
  network_security_group_id = oci_core_network_security_group.nsg.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination_type          = "CIDR_BLOCK"
  destination               = "0.0.0.0/0"
  description               = "Allow all outbound traffic"
}
