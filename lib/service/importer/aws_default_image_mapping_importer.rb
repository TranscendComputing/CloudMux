class AwsDefaultImageMappingImporter

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

####### Mapping Constants ########
# Types
DEFAULT_IMAGE_MAP        = "image"

# Properties
IMAGE_ID		    = "image_id"
REGION              = "region"
REGION_DISP         = "region_display"
OS                  = "operating_system"
ICON                = "icon"
VT                  = "virtualization_type"
HYP                 = "hypervisor"
ARCH                = "architecture"
RDT                 = "root_device_type"
DESCRIPTION         = "description"
# Property Values
ARCH_64             = "x86_64"
ARCH_32             = "i386"
RDT_S3              = "S3"
RDT_EBS             = "ebs"
LINUX               = "linux"
WINDOWS             = "windows"
AMAZON              = "amazon"  
PARAV               = "paravirtual" 

###### Mapping Properties ######
AWS_LINUX_PROPS = {
    :description => "The Amazon Linux AMI 2012.03 is an EBS-backed, PV-GRUB image. It includes Linux 3.2, AWS tools, and repository access to multiple versions of MySQL, PostgreSQL, Python, Ruby, and Tomcat.",
    :x86_64 => {:ami => "ami-e565ba8c"},
    :i386 => {:ami => "ami-ed65ba84"},
    :icon => AMAZON,
    :operating_system => LINUX,
    :root_device_type => RDT_EBS,
    :virtualization_type => PARAV,
    :hypervisor => "xen"
}

RED_HAT_PROPS = {
    :description => "Red Hat Enterprise Linux version 6.2, EBS-boot.",
    :x86_64 => {
        :ami => "ami-41d00528"
    },
    :i386 => {
        :ami => "ami-cdd306a4"
    },
    :operating_system => LINUX,
    :icon => "redhat",
    :root_device_type => RDT_EBS,
    :virtualization_type => "paravirtual",
    :hypervisor => "xen"
}

SUSE_PROPS = {
    :description => "SUSE Linux Enterprise Server 11 Service Pack 2 basic install, EBS boot with Amazon EC2 AMI Tools preinstalled; Apache 2.2, MySQL 5.0, PHP 5.3, and Ruby 1.8.7",
    :x86_64 => {
        :ami => "ami-ca32efa3"
    },
    :i386 => {
        :ami => "ami-0c32ef65"
    },
    :operating_system => LINUX,
    :icon => "suse",
    :root_device_type => RDT_EBS,
    :virtualization_type => "paravirtual",
    :hypervisor => "xen"
}

UBUNTU_12_PROPS = {
    :description => "Ubuntu Server 12.04 LTS with support available from Canonical.",
    :x86_64 => {
        :ami => "ami-a29943cb"
    },
    :i386 => {
        :ami => "ami-ac9943c5"
    },
    :operating_system => LINUX,
    :icon => "ubuntu",
    :root_device_type => RDT_EBS,
    :virtualization_type => "paravirtual",
    :hypervisor => "xen"
}

UBUNTU_10_PROPS = {
    :description => "Ubuntu Server version 11.10, with support available from Canonical.",
    :x86_64 => {
        :ami => "ami-baba68d3"
    },
    :i386 => {
        :ami => "ami-a0ba68c9"
    },
    :operating_system => LINUX,
    :icon => "ubuntu",
    :root_device_type => RDT_EBS,
    :virtualization_type => "paravirtual",
    :hypervisor => "xen"
}



WINDOWS_2008_BASE = {
    :description => "Microsoft Windows 2008 R1 SP2 Datacenter edition.",
    :x86_64 => {
        :ami => "ami-92cc6ffb"
    },
    :i386 => {
        :ami => "ami-10cc6f79"
    },
    :operating_system => WINDOWS,
    :icon => WINDOWS,
    :root_device_type => RDT_EBS,
    :virtualization_type => "hvm",
    :hypervisor => "xen"
}

WINDOWS_2008_R2_BASE= {
    :description => "Microsoft Windows 2008 R2 SP1 Datacenter edition and 64-bit architecture.",
    :x86_64 => {
        :ami => "ami-2ccd6e45"
    },
    :operating_system => WINDOWS,
    :icon => WINDOWS,
    :root_device_type => RDT_EBS,
    :virtualization_type => "hvm",
    :hypervisor => "xen"
}

WINDOWS_2008_SP1_EXPRESS = {
    :description => "Microsoft Windows Server 2008 R2 SP1 Datacenter edition, 64-bit architecture, Microsoft SQLServer 2008 Express, Internet Information Services 7, ASP.NET 3.5.",
    :x86_64 => {
        :ami => "ami-06cd6e6f"
    },
    :operating_system => WINDOWS,
    :icon => WINDOWS,
    :root_device_type => RDT_EBS,
    :virtualization_type => "hvm",
    :hypervisor => "xen"
}   

WINDOWS_2008_SP1_WEB_ED = {
    :description => "Microsoft Windows Server 2008 R2 SP1 Datacenter, 64-bit architecture, Microsoft SQL Server 2008 R2 Web Edition.",
    :x86_64 => {
        :ami => "ami-d4cd6ebd"
    },
    :operating_system => WINDOWS,
    :icon => WINDOWS,
    :root_device_type => RDT_EBS,
    :virtualization_type => "hvm",
    :hypervisor => "xen"
}

AWS_LINUX_CLUSTER_GPU = {
    :description => "The Cluster GPU Amazon Linux AMI 2012.03 is an EBS-backed, HVM image. It includes Linux 3.2, AWS tools, and repository access to multiple versions of MySQL, PostgreSQL, Python, Ruby, and Tomcat. GPU support is handled via the Nvidia GPU driver, GPU SDK 4.1, and CUDA toolkit 4.1.",
    :x86_64 => {
        :ami => "ami-fd65ba94"
    },
    :operating_system => LINUX,
    :icon => AMAZON,
    :root_device_type => RDT_EBS,
    :virtualization_type => "hvm",
    :hypervisor => "xen"
}

SUSE_CLUSTER = {
    :description => "SUSE Linux Enterprise Server 11 Service Pack 2, 64-bit architecture, and HVM based virtualization for use with Amazon EC2 Cluster Compute and Cluster GPU instances. Nvidia driver installs automatically during startup.",
    :x86_64 => {
        :ami => "ami-c02df0a9"
    },
    :operating_system => LINUX,
    :icon => "suse",
    :root_device_type => RDT_EBS,
    :virtualization_type => "hvm",
    :hypervisor => "xen"
}

WINDOWS_2008_SQL_STANDARD = {
    :description => "Microsoft Windows Server 2008 R2 SP1 Datacenter edition, 64-bit architecture, Microsoft SQL Server 2008 R2.",
    :x86_64 => {
        :ami => "ami-d6cd6ebf"
    },
    :operating_system => WINDOWS,
    :icon => WINDOWS,
    :root_device_type => RDT_EBS,
    :virtualization_type => "hvm",
    :hypervisor => "xen"
}

AWS_LINUX_CLUSTER_COMPUTE = {
    :description => "The Amazon Linux AMI 2012.03 is an EBS-backed, HVM image. It includes Linux 3.2, AWS tools, and repository access to multiple versions of MySQL, PostgreSQL, Python, Ruby, and Tomcat.",
    :x86_64 => {
        :ami => "ami-e965ba80"
    },
    :operating_system => LINUX,
    :icon => AMAZON,
    :root_device_type => RDT_EBS,
    :virtualization_type => "hvm",
    :hypervisor => "xen"
}

WINDOWS_2008_CLUSTER = {
    :description => "Microsoft Windows 2008 R2 SP1, 64 bit architecture, for use with Cluster Instances. Includes Nvidia GPU driver.",
    :x86_64 => {
        :ami => "ami-38cd6e51"
    },
    :operating_system => WINDOWS,
    :icon => WINDOWS,
    :root_device_type => RDT_EBS,
    :virtualization_type => "hvm",
    :hypervisor => "xen"
}

WINDOWS_2008_SQL_CLUSTER = {
    :description => "Microsoft Windows 2008 R2 SP1, 64 bit architecture, with SQL Server, for use with Cluster Instances. Includes Nvidia GPU driver.",
    :x86_64 => {
        :ami => "ami-eace6d83"
    },
    :operating_system => WINDOWS,
    :icon => WINDOWS,
    :root_device_type => RDT_EBS,
    :virtualization_type => "hvm",
    :hypervisor => "xen"
}

UBUNTU_12_CLUSTER = {
    :description => "Ubuntu Server 12.04 LTS, with support available from Canonical. For use with Cluster Instances.",
    :x86_64 => {
        :ami => "ami-a69943cf"
    },
    :operating_system => LINUX,
    :icon => "ubuntu",
    :root_device_type => RDT_EBS,
    :virtualization_type => "hvm",
    :hypervisor => "xen"
}


####### Creates default CF Template Image Mappings ############ 
  def import(cloud)
    puts "Creating #{cloud.name} Default Image Mappings (for cloud management use)"

    @default_maps = []
    
    build_map("Amazon Linux AMI 2012.03", AWS_LINUX_PROPS)
    
    build_map("Red Hat Enterprise Linux 6.2", RED_HAT_PROPS)
    build_map("SUSE Linux Enterprise Server 11", SUSE_PROPS)
    build_map("Ubuntu Server 12.04 LTS", UBUNTU_12_PROPS)
    build_map("Ubuntu Server 11.10", UBUNTU_10_PROPS)
    build_map("Microsoft Windows Server 2008 Base", WINDOWS_2008_BASE)
    build_map("Microsoft Windows Server 2008 R2 Base", WINDOWS_2008_R2_BASE)
    build_map("Microsoft Windows Server 2008 R2 with SQL Server Express and IIS", WINDOWS_2008_SP1_EXPRESS)
    build_map("Microsoft Windows Server 2008 R2 with SQL Server Web", WINDOWS_2008_SP1_WEB_ED)
    build_map("Cluster GPU Amazon Linux AMI 2012.03", AWS_LINUX_CLUSTER_GPU)
    build_map("Cluster Instances HVM SUSE Linux Enterprise 11", SUSE_CLUSTER)
    build_map("Microsoft Windows Server 2008 R2 with SQL Server Standard", WINDOWS_2008_SQL_STANDARD)
    build_map("Cluster Compute Amazon Linux AMI 2012.03", AWS_LINUX_CLUSTER_COMPUTE)
    build_map("Microsoft Windows 2008 R2 64-bit for Cluster Instances", WINDOWS_2008_CLUSTER)
    build_map("Microsoft Windows 2008 R2 SQL Server 64-bit for Cluster Instances", WINDOWS_2008_SQL_CLUSTER)
    build_map("Ubuntu Server 12.04 LTS for Cluster Instances", UBUNTU_12_CLUSTER)

    @default_maps.each do |map|
        puts "Adding \"#{map.name}\" to #{cloud.name} cloud mappings"
        map.mappable = cloud
        begin
            map.save!
        rescue => e
            log " skipping - failed to save: #{e}\n#{e.backtrace.join("\n")}"
        end
    end
  end
  
  def build_map(name, properties)
    map = CloudMapping.new
    map.name = name
    map.properties = properties
    map.mapping_type = DEFAULT_IMAGE_MAP
    @default_maps << map
  end
  
  def log(message)
    puts message unless ENV["RACK_ENV"] == "test"
  end
end
